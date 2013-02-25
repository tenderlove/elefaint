require 'gserver'
require 'set'
Thread.abort_on_exception = true

module Elefaint
  VERSION = '1.0.0'

  module Nodes
    class MultiBulk
      def initialize children
        @children = children
      end

      def each(&blk); @children.each(&blk); end

      def to_a
        @children.map { |c| c.value }
      end

      def to_str
        "*#{@children.length}\r\n" + @children.map(&:to_str).join
      end
    end

    Bulk   = Struct.new(:value) {
      def to_str
        "$#{value.length}\r\n#{value}\r\n"
      end
    }

    Status = Struct.new(:value) {
      def to_str
        "+#{value}\r\n"
      end
    }
    Integer = Struct.new(:value) {
      def to_str
        ":#{value}\r\n"
      end
    }
    Null = Struct.new(:value) {
      def to_str
        "$-1\r\n"
      end
    }
    NULL = Null.new
  end

  class Parser
    def parse io
      x = io.readchar
      case x
      when '+' then Nodes::Status.new io.readline.chomp
      when '-' then raise(NotImplementedError)
      when ':' then Nodes::Integer.new io.readline.chomp
      when '$' then parse_bulk(io)
      when '*' then parse_multi_bulk(io)
      else
        raise x
      end
    end

    private
    def parse_multi_bulk io
      Nodes::MultiBulk.new io.readline.chomp.to_i.times.map { parse io }
    end

    def parse_bulk io
      num = io.readline.chomp.to_i
      if num == -1
        Nodes::NULL
      else
        Nodes::Bulk.new io.read(num + 2).chomp
      end
    end
  end

  PARSER = Parser.new # :nodoc:
  OK     = Nodes::Status.new "OK"


  module Stores
    class Memory
      STORE = []

      def initialize
        @dbnum = 0
      end

      def select cmd
        @dbnum = cmd.first.to_i
        STORE[@dbnum] ||= Hash.new { |h,k| h[k] = Set.new }
        OK
      end

      def flushdb cmd
        db.clear
        OK
      end

      def quit cmd
        OK
      end

      def smembers cmd
        STORE[@dbnum]
        Nodes::MultiBulk.new db[cmd.shift].map { |v|
          Nodes::Bulk.new v
        }.reverse
      end

      def sadd cmd
        set = db[cmd.shift]
        x = set.size
        cmd.each { |i| set << i }
        Nodes::Integer.new(set.size - x)
      end

      def scard cmd
        set = db[cmd.shift]
        Nodes::Integer.new set.size
      end

      def sdiffstore cmd
        dest = cmd.shift
        diff = cmd.drop(1).inject(db[cmd.first]) { |m, s|
          m - db[s]
        }
        db[dest] = diff
        Nodes::Integer.new diff.size
      end

      def sdiff cmd
        diff = cmd.drop(1).inject(db[cmd.first]) { |m, s|
          m - db[s]
        }
        Nodes::MultiBulk.new diff.map { |v| Nodes::Bulk.new v }
      end

      def sinterstore cmd
        dest = cmd.shift
        inter = cmd.drop(1).inject(db[cmd.first]) { |m, s|
          m & db[s]
        }
        db[dest] = inter
        Nodes::Integer.new inter.size
      end

      def sinter cmd
        diff = cmd.drop(1).inject(db[cmd.first]) { |m, s|
          m & db[s]
        }
        Nodes::MultiBulk.new diff.map { |v| Nodes::Bulk.new v }
      end

      def sismember cmd
        if db[cmd.first].member? cmd.last
          Nodes::Integer.new 1
        else
          Nodes::Integer.new 0
        end
      end

      def smove cmd
        source, dest, member = *cmd
        if db[source].member? member
          db[source].delete member
          db[dest] << member
          Nodes::Integer.new 1
        else
          Nodes::Integer.new 0
        end
      end

      def spop cmd
        set = db[cmd.first]
        val = set.first
        if val
          set.delete val
          Nodes::Bulk.new val
        else
          Nodes::NULL
        end
      end

      def srandmember cmd
        set   = db[cmd.first]
        count = (cmd[1] || 1).to_i

        if count >= 0
          chosen = set.first(count)
          if count == 1
            Nodes::Bulk.new chosen.first
          else
            Nodes::MultiBulk.new chosen.map { |v| Nodes::Bulk.new v }
          end
        else
          raise NotImplementedError
        end
      end

      def srem cmd
        set   = db[cmd.first]
        mbers = cmd.drop(1).find_all { |y| set.member? y }
        mbers.each { |m| set.delete m }
        Nodes::Integer.new mbers.length
      end

      def sunion cmd
        diff = cmd.drop(1).inject(db[cmd.first]) { |m, s|
          m | db[s]
        }
        Nodes::MultiBulk.new diff.map { |v| Nodes::Bulk.new v }
      end

      def sunionstore cmd
        dest = cmd.shift
        diff = cmd.drop(1).inject(db[cmd.first]) { |m, s|
          m | db[s]
        }
        db[dest] = diff
        Nodes::Integer.new diff.length
      end

      def _process cmd
        args   = cmd.to_a
        method = args.shift
        yield method if block_given?
        send method, args
      end

      if $DEBUG
        def send method, *args
          p [Thread.current.object_id, method.upcase => args]
          super
        end
      end

      private
      def db
        STORE[@dbnum]
      end
    end
  end

  class Server < GServer
    def initialize port = 6381, *args
      super
    end

    def serve io
      machine = Stores::Memory.new
      socket  = TCPSocket.new 'localhost', 7777

      loop do
        cmd = PARSER.parse(io)

        puts "request #{cmd.to_str.inspect}"
        socket.write cmd.to_str
        redis_res = PARSER.parse socket
        puts "response #{redis_res.to_str.inspect}"

        method = nil
        my_res = machine._process(cmd) { |m| method = m }

        io.write my_res.to_str
        break if method == "quit"
      end
    end
  end
end

if $0 == __FILE__
server = Elefaint::Server.new

trap(:INT) {
  server.shutdown
  exit
}

server.start
server.join
end
