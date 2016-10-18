require 'oven/path_parser'

module Oven
  class DslContext < BasicObject
    attr_reader :method_definitions, :interceptors, :observers, :requires, :extensions

    def initialize(extensions, format_mapping)
      @method_definitions = []
      @interceptors = []
      @observers = []
      @requires = []
      @extensions = extensions || []
      @format_mapping = format_mapping || {}
    end

    def format(format)
      @extensions << @format_mapping.fetch(format).new
    end

    def configure(extension)
      extension.configure_interceptors(@interceptors) if extension.respond_to?(:configure_interceptors)
      extension.configure_observers(@observers) if extension.respond_to?(:configure_observers)
      extension.configure_requires(@requires) if extension.respond_to?(:configure_requires)
    end

    def get(resource_name, path, as: nil)
      @method_definitions << Get.new(resource_name, path, as: as)
    end

    def post(resource_name, path, as: nil)
      @method_definitions << Post.new(resource_name, path, as: as)
    end

    def patch(resource_name, path, as: nil)
      @method_definitions << Patch.new(resource_name, path, as: as)
    end

    def delete(resource_name, path, as: nil)
      @method_definitions << Delete.new(resource_name, path, as: as)
    end

    class HttpVerb
      attr_reader :name, :method_name, :aliases

      def initialize(name, path, as: nil)
        @name        = name
        @path_ast    = Oven::PathParser.parse(path)
        @method_name = as || "#{verb}_#{name}"
        @aliases     = as ? [] : nil
      end

      def verb
        raise NotImplementedError
      end

      def variable_name_for_body
        raise NotImplementedError
      end

      def path
        @path_ast.to_argument_expression
      end

      def parameters
        @path_ast.parameters
      end

      def parameter_signature
        parameters.join(", ")
      end
    end

    class Get < HttpVerb
      def verb
        :get
      end

      def variable_name_for_body
        'nil'
      end

      def aliases
        super || ["find_#{name}"]
      end
    end

    class Post < HttpVerb
      def verb
        :post
      end

      def parameters
        super.dup << :body
      end

      def variable_name_for_body
        'body'
      end

      def aliases
        super || ["create_#{name}"]
      end
    end

    class Patch < HttpVerb
      def verb
        :patch
      end

      def parameters
        super.dup << :body
      end

      def variable_name_for_body
        'body'
      end

      def aliases
        super || ["update_#{name}"]
      end
    end

    class Delete < HttpVerb
      def verb
        :delete
      end

      def variable_name_for_body
        'nil'
      end

      def aliases
        super || ["destroy_#{name}"]
      end
    end

    private_constant :HttpVerb, :Get, :Post, :Patch, :Delete
  end

  private_constant :DslContext
end
