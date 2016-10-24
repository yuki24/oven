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
      @method_definitions << HttpVerb.new(:get, resource_name, path, as: as, aliases: ["find_#{resource_name}"], has_entity: false)
    end

    def head(resource_name, path, as: nil)
      @method_definitions << HttpVerb.new(:head, resource_name, path, as: as, aliases: [], has_entity: false)
    end

    def post(resource_name, path, as: nil)
      @method_definitions << HttpVerb.new(:post, resource_name, path, as: as, aliases: ["create_#{resource_name}"], has_entity: true)
    end

    def put(resource_name, path, as: nil)
      @method_definitions << HttpVerb.new(:put, resource_name, path, as: as, aliases: ["update_#{resource_name}"], has_entity: true)
    end

    def patch(resource_name, path, as: nil)
      @method_definitions << HttpVerb.new(:patch, resource_name, path, as: as, aliases: ["update_#{resource_name}"], has_entity: true)
    end

    def delete(resource_name, path, as: nil)
      @method_definitions << HttpVerb.new(:delete, resource_name, path, as: as, aliases: ["destroy_#{resource_name}"], has_entity: false)
    end

    def options(resource_name, path, as: nil)
      @method_definitions << HttpVerb.new(:options, resource_name, path, as: as, aliases: [], has_entity: false)
    end

    class HttpVerb
      attr_reader :verb, :name, :method_name, :aliases

      def initialize(verb, name, path, as: nil, aliases: [], has_entity: false)
        @verb        = verb
        @name        = name
        @path_ast    = Oven::PathParser.parse(path)
        @method_name = as || "#{verb}_#{name}"
        @aliases     = as ? [] : aliases
        @has_entity  = has_entity
      end

      def variable_name_for_body
        @has_entity ? 'body' : 'nil'
      end

      def path
        @path_ast.to_argument_expression
      end

      def parameters
        @path_ast.parameters + (@has_entity ? [:body] : [])
      end

      def parameter_signature
        parameters.join(", ")
      end
    end

    private_constant :HttpVerb
  end

  private_constant :DslContext
end
