require 'minitest/autorun'
require 'elefaint'
require 'stringio'

module Elefaint
  class TestCase < MiniTest::Unit::TestCase
  end

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

    def test_roundtrip
      [
        "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n",
        "+OK\r\n",
        ":123\r\n",
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
__END__
{:ZOOMG=>"*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"}
{:ZOOMG=>"*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"}
{:ZOOMG=>"*1\r\n$7\r\nflushdb\r\n"}
{:ZOOMG=>"*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"}
{:ZOOMG=>"*1\r\n$7\r\nflushdb\r\n"}
{:ZOOMG=>"*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"}
{:ZOOMG=>"*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"}
{:ZOOMG=>"*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"}
{:ZOOMG=>"*2\r\n$8\r\nsmembers\r\n$3\r\nfoo\r\n"}
{:ZOOMG=>"*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"}
{:ZOOMG=>"*2\r\n$8\r\nsmembers\r\n$3\r\nfoo\r\n"}
{:ZOOMG=>"*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"}
{:ZOOMG=>"*1\r\n$4\r\nquit\r\n"}
