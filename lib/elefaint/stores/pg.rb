require 'pg'
require 'uri'

module Elefaint
  module Stores
    class PG
      class StatementCache
        attr_reader :cache

        def initialize(connection, max)
          @connection = connection
          @max        = max
          @counter    = 0
          @cache      = {}
        end

        def each(&block); cache.each(&block); end
        def key?(key);    cache.key?(key); end
        def [](key);      cache[key]; end
        def length;       cache.length; end

        def next_key
          "a#{@counter + 1}"
        end

        def []=(sql, key)
          while @max <= cache.size
            dealloc(cache.shift.last)
          end
          @counter += 1
          cache[sql] = key
        end

        def clear
          cache.each_value do |stmt_key|
            dealloc stmt_key
          end
          cache.clear
        end

        def delete(sql_key)
          dealloc cache[sql_key]
          cache.delete sql_key
        end

        private

        def dealloc(key)
          @connection.query "DEALLOCATE #{key}" if connection_active?
        end

        def connection_active?
          @connection.status == PGconn::CONNECTION_OK
        rescue PGError
          false
        end
      end

      include Processable

      attr_reader :conn

      def initialize url
        url = URI(url)

        host = url.host
        dbname = url.path.sub(/^\//, '')

        @dbnum      = 0
        @conn       = ::PG::Connection.new :host => host, :dbname => dbname
        @stmt_cache = StatementCache.new @conn, 20
      end

      def select cmd
        @dbnum = cmd.first.to_i
        Nodes::OK
      end

      def flushdb cmd
        transaction do
          conn.exec 'DELETE FROM redis_sets'
          conn.exec 'DELETE FROM redis_lists'
        end
        Nodes::OK
      end

      SADD = <<-eosql
        INSERT INTO redis_sets (name, value)
        SELECT $1::varchar, $2::varchar WHERE NOT EXISTS(
          SELECT id FROM redis_sets WHERE name = $1 AND value = $2
        ) RETURNING id
      eosql

      def sadd cmd
        count    = 0
        set_name = cmd.shift

        transaction do
          stmt     = stmt_for SADD
          cmd.each do |value|
            conn.send_query_prepared stmt, [set_name, value]
            conn.block
            result = conn.get_last_result
            count += 1 unless result.values.empty?
          end
        end
        Nodes::Integer.new count
      end

      SMEMBERS = 'SELECT value FROM redis_sets WHERE name = $1 ORDER BY id DESC'

      def smembers cmd
        stmt = stmt_for SMEMBERS
        conn.send_query_prepared stmt, [cmd.first]
        conn.block
        result = conn.get_last_result

        Nodes::MultiBulk.new result.values.map { |v|
          Nodes::Bulk.new v.first
        }
      end

      SISMEMBER = 'SELECT COUNT(1) FROM redis_sets WHERE name = $1 AND value = $2'
      def sismember cmd
        stmt = stmt_for SISMEMBER
        conn.send_query_prepared stmt, cmd
        conn.block
        result = conn.get_last_result
        Nodes::Integer.new result.values.first.first.to_i
      end

      SINTER = 'SELECT value FROM redis_sets WHERE name = '

      def sinter cmd
        sql = cmd.length.times.map { |i| SINTER + "$#{i+1}" }.join ' INTERSECT '
        stmt = stmt_for sql
        conn.send_query_prepared stmt, cmd
        conn.block
        result = conn.get_last_result
        Nodes::MultiBulk.new result.values.flatten.map { |v| Nodes::Bulk.new v}
      end

      SRANDMEMBER = <<-eosql
        SELECT value
        FROM redis_sets
        WHERE name = $1
        ORDER BY random()
        LIMIT $2
      eosql

      def srandmember cmd
        count = (cmd[1] || 1).to_i

        stmt = stmt_for SRANDMEMBER
        conn.send_query_prepared stmt, [cmd.first, count]
        conn.block
        result = conn.get_last_result

        if count >= 0
          if count == 1
            Nodes::Bulk.new result.values.first.first
          else
            Nodes::MultiBulk.new result.values.flatten.map { |v| Nodes::Bulk.new v }
          end
        else
          raise NotImplementedError
        end
      end

      SMOVE = <<-eosql
        UPDATE redis_sets
        SET name = $1
        WHERE name = $2 AND value = $3 RETURNING id
      eosql

      def smove cmd
        source, dest, member = *cmd

        stmt = stmt_for SMOVE
        conn.send_query_prepared stmt, [dest, source, member]
        conn.block
        result = conn.get_last_result
        if result.values.any?
          Nodes::Integer.new 1
        else
          Nodes::Integer.new 0
        end
      end

      SCARD = 'SELECT COUNT(*) FROM redis_sets WHERE name = $1'

      def scard cmd
        stmt = stmt_for SCARD
        conn.send_query_prepared stmt, cmd
        conn.block
        result = conn.get_last_result
        Nodes::Integer.new result.values.flatten.first
      end

      def info cmd
        Nodes::Bulk.new "# Server\r\nredis_version:2.6.10"
      end

      SPOP = <<-eosql
        DELETE FROM redis_sets
          WHERE id IN
            (SELECT id FROM redis_sets WHERE name = $1 LIMIT 1)
        RETURNING value
      eosql

      def spop cmd
        stmt = stmt_for SPOP
        conn.send_query_prepared stmt, cmd
        conn.block
        result = conn.get_last_result
        if result.values.any?
          Nodes::Bulk.new result.values.first.first
        else
          Nodes::NULL
        end
      end

      def quit cmd
        @stmt_cache.clear
        conn.finish
        Nodes::OK
      end

      def reset!
        transaction do
          conn.exec "DROP TABLE IF EXISTS redis_sets"
          conn.exec "DROP TABLE IF EXISTS redis_lists"
          conn.exec <<-eosql
            CREATE TABLE redis_sets(
              id SERIAL,
              name varchar,
              value varchar,
              created_at timestamp default current_timestamp
            );
          eosql
          conn.exec 'CREATE UNIQUE INDEX redis_sets_name_value ON redis_sets (name, value)'
          conn.exec <<-eosql
            CREATE TABLE redis_lists(
              id SERIAL,
              name varchar,
              value varchar,
              created_at timestamp default current_timestamp
            );
          eosql
        end
      end

      private

      def stmt_for sql
        unless @stmt_cache.key? sql
          nextkey = @stmt_cache.next_key
          conn.prepare nextkey, sql
          @stmt_cache[sql] = nextkey
        end
        @stmt_cache[sql]
      end

      def transaction
        conn.exec "BEGIN"
        yield
        conn.exec "COMMIT"
      rescue Exception
        conn.exec "ROLLBACK"
        raise
      end
    end
  end
end
