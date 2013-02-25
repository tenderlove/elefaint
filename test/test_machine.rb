require 'helper'

module Elefaint
  class TestMemory < TestCase
    def setup
      @parser  = Parser.new
      @machine = Stores::Memory.new
    end

    def test_sadd
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":0\r\n"
      request "*2\r\n$8\r\nsmembers\r\n$3\r\nfoo\r\n"
      response "*2\r\n$2\r\ns2\r\n$2\r\ns1\r\n"
      request "*1\r\n$4\r\nquit\r\n"
      response "+OK\r\n"
    end

    def test_scard
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*2\r\n$5\r\nscard\r\n$3\r\nfoo\r\n"
      response ":0\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*2\r\n$5\r\nscard\r\n$3\r\nfoo\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*2\r\n$5\r\nscard\r\n$3\r\nfoo\r\n"
      response ":2\r\n"
      request "*1\r\n$4\r\nquit\r\n"
      response "+OK\r\n"
    end

    def test_sdiff
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nbar\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nbar\r\n$2\r\ns3\r\n"
      response ":1\r\n"
      request "*3\r\n$5\r\nsdiff\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"
      response "*1\r\n$2\r\ns1\r\n"
      request "*3\r\n$5\r\nsdiff\r\n$3\r\nbar\r\n$3\r\nfoo\r\n"
      response "*1\r\n$2\r\ns3\r\n"
      request "*1\r\n$4\r\nquit\r\n"
      response "+OK\r\n"
    end

    def test_sdiffstore
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nbar\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nbar\r\n$2\r\ns3\r\n"
      response ":1\r\n"
      request "*4\r\n$10\r\nsdiffstore\r\n$3\r\nbaz\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"
      response ":1\r\n"
      request "*2\r\n$8\r\nsmembers\r\n$3\r\nbaz\r\n"
      response "*1\r\n$2\r\ns1\r\n"
      request "*1\r\n$4\r\nquit\r\n"
      response "+OK\r\n"
    end

    def test_sinter
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nbar\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*3\r\n$6\r\nsinter\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"
      response "*1\r\n$2\r\ns2\r\n"
      request "*1\r\n$4\r\nquit\r\n"
      response "+OK\r\n"
    end

    def test_sinterstore
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"
      response "+OK\r\n"
      request "*1\r\n$7\r\nflushdb\r\n"
      response "+OK\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nbar\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*4\r\n$11\r\nsinterstore\r\n$3\r\nbaz\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"
      response ":1\r\n"
      request "*2\r\n$8\r\nsmembers\r\n$3\r\nbaz\r\n"
      response "*1\r\n$2\r\ns2\r\n"
      request "*1\r\n$4\r\nquit\r\n"
      response "+OK\r\n"
    end

    private

    def request str
      cmd = PARSER.parse io str
      args   = cmd.to_a
      method = args.shift
      @response = @machine.send method, args
    end

    def response str
      assert_equal str, @response.to_str
    end
  end
end
