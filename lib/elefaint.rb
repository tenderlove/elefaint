require 'elefaint/nodes'
require 'elefaint/server'
require 'set'

module Elefaint
  VERSION = '1.0.0'
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
