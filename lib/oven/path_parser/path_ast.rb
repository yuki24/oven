module Oven
  class PathAst
    include Enumerable

    def initialize(expressions)
      @expressions = expressions
    end

    def each(&block)
      @expressions.each(&block)
    end

    def to_argument_expression
      map(&:to_argument_expression).join
    end

    def parameters
      select(&:argument?).map(&:to_sym)
    end
  end
end
