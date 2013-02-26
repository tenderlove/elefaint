module Elefaint
  module Stores
    module Processable
      def _process cmd
        args   = cmd.to_a
        method = args.shift
        yield method if block_given?
        send method, args
      end
    end

    class Memory
      include Processable

      def initialize
        @dbnum = 0
        @sets  = []
        @lists = []
      end

      def select cmd
        @dbnum = cmd.first.to_i
        @sets[@dbnum] ||= Hash.new { |h,k| h[k] = Set.new }
        @lists[@dbnum] ||= Hash.new { |h,k| h[k] = [] }
        Nodes::OK
      end

      def flushdb cmd
        sets.clear
        Nodes::OK
      end

      def quit cmd
        Nodes::OK
      end

      def smembers cmd
        Nodes::MultiBulk.new sets[cmd.shift].map { |v|
          Nodes::Bulk.new v
        }.reverse
      end

      def sadd cmd
        set = sets[cmd.shift]
        x = set.size
        cmd.each { |i| set << i }
        Nodes::Integer.new(set.size - x)
      end

      def scard cmd
        set = sets[cmd.shift]
        Nodes::Integer.new set.size
      end

      def sdiffstore cmd
        dest = cmd.shift
        diff = cmd.drop(1).inject(sets[cmd.first]) { |m, s|
          m - sets[s]
        }
        sets[dest] = diff
        Nodes::Integer.new diff.size
      end

      def sdiff cmd
        diff = cmd.drop(1).inject(sets[cmd.first]) { |m, s|
          m - sets[s]
        }
        Nodes::MultiBulk.new diff.map { |v| Nodes::Bulk.new v }
      end

      def sinterstore cmd
        dest = cmd.shift
        inter = cmd.drop(1).inject(sets[cmd.first]) { |m, s|
          m & sets[s]
        }
        sets[dest] = inter
        Nodes::Integer.new inter.size
      end

      def sinter cmd
        diff = cmd.drop(1).inject(sets[cmd.first]) { |m, s|
          m & sets[s]
        }
        Nodes::MultiBulk.new diff.map { |v| Nodes::Bulk.new v }
      end

      def sismember cmd
        if sets[cmd.first].member? cmd.last
          Nodes::Integer.new 1
        else
          Nodes::Integer.new 0
        end
      end

      def smove cmd
        source, dest, member = *cmd
        if sets[source].member? member
          sets[source].delete member
          sets[dest] << member
          Nodes::Integer.new 1
        else
          Nodes::Integer.new 0
        end
      end

      def spop cmd
        set = sets[cmd.first]
        val = set.first
        if val
          set.delete val
          Nodes::Bulk.new val
        else
          Nodes::NULL
        end
      end

      def srandmember cmd
        set   = sets[cmd.first]
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
        set   = sets[cmd.first]
        mbers = cmd.drop(1).find_all { |y| set.member? y }
        mbers.each { |m| set.delete m }
        Nodes::Integer.new mbers.length
      end

      def sunion cmd
        diff = cmd.drop(1).inject(sets[cmd.first]) { |m, s|
          m | sets[s]
        }
        Nodes::MultiBulk.new diff.map { |v| Nodes::Bulk.new v }
      end

      def sunionstore cmd
        dest = cmd.shift
        diff = cmd.drop(1).inject(sets[cmd.first]) { |m, s|
          m | sets[s]
        }
        sets[dest] = diff
        Nodes::Integer.new diff.length
      end

      def info cmd
        Nodes::Bulk.new "# Server\r\nredis_version:2.6.10"
      end

      def rpush cmd
        dest = cmd.shift
        lists[dest].concat cmd
        Nodes::Integer.new lists[dest].length
      end

      def llen cmd
        Nodes::Integer.new lists[cmd.first].length
      end

      def rpop cmd
        Nodes::Bulk.new lists[cmd.first].pop
      end

      if $DEBUG
        def send method, *args
          p [Thread.current.object_id, method.upcase => args]
          super
        end
      end

      private
      def sets
        @sets[@dbnum]
      end

      def lists
        @lists[@dbnum]
      end
    end
  end
end
