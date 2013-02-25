require 'helper'

module Elefaint
  class TestParser < TestCase
    attr_reader :parser

    def setup
      @parser = Parser.new
    end

    def test_parser_blk
      blk = parser.parse io("*2\r\n$6\r\nselect\r\n$2\r\n14\r\n")
      assert_equal ['select', '14'], blk.to_a
    end

    def test_parse_ok
      blk = parser.parse io("+OK\r\n")
      assert_equal 'OK', blk.value
    end

    def test_nil
      blk = parser.parse io("$-1\r\n")
      assert_equal nil, blk.value
    end

    def test_roundtrip
      [
        "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n",
        "+OK\r\n",
        ":123\r\n",
        "$-1\r\n",
      ].each do |val|
        blk = parser.parse io val
        assert_equal val, blk.to_str
      end
    end

    def io string
      StringIO.new string
    end
  end
end
