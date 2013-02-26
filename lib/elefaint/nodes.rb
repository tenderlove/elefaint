module Elefaint
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
    OK   = Nodes::Status.new "OK"
  end
end
