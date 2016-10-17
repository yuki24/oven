module Oven
  module Nodes
    class Expressions
      include Enumerable

      def initialize(values)
        @expressions = values
      end

      def each(&block)
        @expressions.each(&block)
      end
    end

    class Node
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def to_s
        @value.to_s
      end
      alias to_argument_expression to_s

      def argument?
        false
      end
    end

    class Slash < Node; end
    class Literal < Node; end

    class Symbol < Node
      def to_argument_expression
        "\#{#{value.tr(':', '')}}"
      end

      def argument?
        true
      end

      def to_sym
        value.tr(":", "").to_sym
      end
    end
  end
end
