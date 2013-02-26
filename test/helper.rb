require 'minitest/autorun'
require 'elefaint'
require 'elefaint/parser'
require 'stringio'

module Elefaint
  class TestCase < MiniTest::Unit::TestCase
    def io str
      StringIO.new str
    end
  end
end
