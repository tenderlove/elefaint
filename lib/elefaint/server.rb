require 'gserver'
require 'elefaint/parser'
require 'elefaint/stores/memory'

Thread.abort_on_exception = true

module Elefaint
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
