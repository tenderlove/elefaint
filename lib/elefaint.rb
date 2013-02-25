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
      end
    end

    private
    def parse_multi_bulk io
      Nodes::MultiBulk.new io.readline.chomp.to_i.times.map { parse io }
    end

    def parse_bulk io
      Nodes::Bulk.new io.read(io.readline.chomp.to_i + 2).chomp
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

      def sinter cmd
        diff = cmd.drop(1).inject(db[cmd.first]) { |m, s|
          m & db[s]
        }
        Nodes::MultiBulk.new diff.map { |v| Nodes::Bulk.new v }
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

        args   = cmd.to_a
        method = args.shift

        my_res = machine.send method, args
        assert_equal redis_res.to_str, my_res.to_str
        io.write my_res.to_str

        break if method == "quit"
      end
    end

    private
    def assert_equal exp, act
      unless exp == act
        raise "expected #{exp.chomp.gsub(/\r\n/, ';')} == #{act.chomp.gsub(/\r\n/, ';')}"
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
