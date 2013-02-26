require 'helper'
require 'store_tests'
require 'elefaint/stores/pg'

module Elefaint
  class TestMemory < TestCase
    include StoreTests

    def setup
      @parser  = Parser.new
      @machine = Stores::Memory.new
    end
  end

  class TestPg < TestCase
    include StoreTests

    def setup
      @parser  = Parser.new
      @machine = Stores::PG.new 'postgresql://localhost/postgres'
      @machine.reset!
    end
  end
end
