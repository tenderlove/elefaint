module Elefaint
  module StoreTests
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

    def test_ismember
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
      request "*3\r\n$9\r\nsismember\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":0\r\n"
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$9\r\nsismember\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$9\r\nsismember\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"
      response ":0\r\n"
      request "*1\r\n$4\r\nquit\r\n"
      response "+OK\r\n"
    end

    def test_smove
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
      request "*3\r\n$4\r\nsadd\r\n$3\r\nbar\r\n$2\r\ns2\r\n"
      response ":1\r\n"
      request "*4\r\n$5\r\nsmove\r\n$3\r\nfoo\r\n$3\r\nbar\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$9\r\nsismember\r\n$3\r\nbar\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*1\r\n$4\r\nquit\r\n"
      response "+OK\r\n"
    end

    def test_spop
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n" # 70121457169680
      response "+OK\r\n" # 70121457169680
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n" # 70121457169680
      response "+OK\r\n" # 70121457169680
      request "*1\r\n$7\r\nflushdb\r\n" # 70121457169680
      response "+OK\r\n" # 70121457169680
      request "*2\r\n$6\r\nselect\r\n$2\r\n15\r\n" # 70121457169680
      response "+OK\r\n" # 70121457169680
      request "*1\r\n$7\r\nflushdb\r\n" # 70121457169680
      response "+OK\r\n" # 70121457169680
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n" # 70121457169680
      response ":1\r\n" # 70121457169680
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns2\r\n" # 70121457169680
      response ":1\r\n" # 70121457169680
      request "*2\r\n$4\r\nspop\r\n$3\r\nfoo\r\n" # 70121457169680
      response "$2\r\ns1\r\n" # 70121457169680
      request "*2\r\n$4\r\nspop\r\n$3\r\nfoo\r\n" # 70121457169680
      response "$2\r\ns2\r\n" # 70121457169680
      request "*2\r\n$4\r\nspop\r\n$3\r\nfoo\r\n" # 70121457169680
      response "$-1\r\n" # 70121457169680
    end

    def test_srandmember
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n" # 70270392039940
      response "+OK\r\n" # 70270392039940
      request "*2\r\n$6\r\nselect\r\n$2\r\n14\r\n" # 70270392039940
      response "+OK\r\n" # 70270392039940
      request "*1\r\n$7\r\nflushdb\r\n" # 70270392039940
      response "+OK\r\n" # 70270392039940
      request "*2\r\n$6\r\nselect\r\n$2\r\n15\r\n" # 70270392039940
      response "+OK\r\n" # 70270392039940
      request "*1\r\n$7\r\nflushdb\r\n" # 70270392039940
      response "+OK\r\n" # 70270392039940
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns1\r\n" # 70270392039940
      response ":1\r\n" # 70270392039940
      request "*3\r\n$4\r\nsadd\r\n$3\r\nfoo\r\n$2\r\ns2\r\n" # 70270392039940
      response ":1\r\n" # 70270392039940
      request "*2\r\n$11\r\nsrandmember\r\n$3\r\nfoo\r\n" # 70270392039940
      assert_match(/^\$2\r\ns[12]\r\n/m, @response.to_str)
    end

    def test_srem
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
      request "*3\r\n$4\r\nsrem\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*2\r\n$6\r\nselect\r\n$2\r\n15\r\n"
      response "+OK\r\n"
      request "*3\r\n$4\r\nsrem\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":0\r\n"
    end

    def test_sunion
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
      request "*3\r\n$6\r\nsunion\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"
      assert_match(/^\*3\r\n\$2\r\ns[123]\r\n\$2\r\ns[123]\r\n\$2\r\ns[123]\r\n/m,
                   @response.to_str)
    end

    def test_sunionstore
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
      request "*4\r\n$11\r\nsunionstore\r\n$3\r\nbaz\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"
      response ":3\r\n"
    end

    def test_info
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
      request "*1\r\n$4\r\ninfo\r\n"
      response "$30\r\n# Server\r\nredis_version:2.6.10\r\n"
    end

    def test_rpush
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
      request "*3\r\n$5\r\nrpush\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
    end

    def test_llen
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
      request "*3\r\n$5\r\nrpush\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$5\r\nrpush\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"
      response ":2\r\n"
      request "*2\r\n$4\r\nllen\r\n$3\r\nfoo\r\n"
      response ":2\r\n"
    end

    def test_rpop
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
      request "*3\r\n$5\r\nrpush\r\n$3\r\nfoo\r\n$2\r\ns1\r\n"
      response ":1\r\n"
      request "*3\r\n$5\r\nrpush\r\n$3\r\nfoo\r\n$2\r\ns2\r\n"
      response ":2\r\n"
      request "*2\r\n$4\r\nllen\r\n$3\r\nfoo\r\n"
      response ":2\r\n"
      request "*2\r\n$4\r\nrpop\r\n$3\r\nfoo\r\n"
      response "$2\r\ns2\r\n"
    end

    private

    def request str
      @response = @machine._process @parser.parse io str
    end

    def response str
      assert_equal str, @response.to_str
    end
  end
end
