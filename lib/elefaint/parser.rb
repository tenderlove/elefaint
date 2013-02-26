module Elefaint
  class Parser
    def parse io
      x = io.readchar
      case x
      when '+' then Nodes::Status.new io.readline.chomp
      when '-' then raise(NotImplementedError)
      when ':' then Nodes::Integer.new io.readline.chomp
      when '$' then parse_bulk(io)
      when '*' then parse_multi_bulk(io)
      else
        raise x
      end
    end

    private
    def parse_multi_bulk io
      Nodes::MultiBulk.new io.readline.chomp.to_i.times.map { parse io }
    end

    def parse_bulk io
      num = io.readline.chomp.to_i
      if num == -1
        Nodes::NULL
      else
        Nodes::Bulk.new io.read(num + 2).chomp
      end
    end
  end

  PARSER = Parser.new # :nodoc:
end
