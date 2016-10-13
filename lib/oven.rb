require "oven/version"
require "oven/http_statuses"
require 'erb'
require 'fileutils'

module Oven
  def self.bake(client_name, destination: './', &block)
    ApiClientBuilder.new(client_name, destination, &block).generate
  end

  class ApiClientBuilder
    API_CLIENT_TEMPALTE     = open("#{__dir__}/oven/templates/client.erb.rb").read
    EXCEPTION_LIST_TEMPLATE = open("#{__dir__}/oven/templates/exceptions.erb.rb").read

    TEMPLATES = {
      '.rb'            => API_CLIENT_TEMPALTE,
      '/exceptions.rb' => EXCEPTION_LIST_TEMPLATE
    }

    attr_reader :client_name, :destination

    def initialize(client_name, destination, &block)
      @client_name, @destination, @block = client_name, destination, block
    end

    def generate
      FileUtils.mkdir_p("#{destination}/#{underscore(client_name)}")
      TEMPLATES.each do |path, template|
        code = ERB.new(template, nil, '-').result(binding)
        path = File.join(destination, "#{underscore(client_name)}#{path}")
        File.write(path, code)
      end
    end

    def method_definitions
      dsl_context.method_definitions
    end

    def interceptors
      dsl_context.interceptors
    end

    def observers
      dsl_context.observers
    end

    private

    def dsl_context
      @dsl_context ||= begin
                         context = DslContext.new
                         context.instance_eval(&@block)
                         context
                       end
    end

    def underscore(camel_cased_word)
      return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
      word = camel_cased_word.to_s.gsub('::', '/')
      word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)(#{/(?=a)b/})(?=\b|[^a-z])/) { "#{$1 && '_'}#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end

  class DslContext < BasicObject
    attr_reader :method_definitions, :interceptors, :observers

    FORMAT_MAPPING = {
      json: "JsonCallback.new"
    }

    def initialize
      @method_definitions = []
      @interceptors = []
      @observers = []
    end

    def format(format)
      @interceptors << FORMAT_MAPPING.fetch(format)
      @observers << FORMAT_MAPPING.fetch(format)
    end

    def get(resource_name, path, as: nil)
      @method_definitions << MethodDefinition::Get.new(resource_name, path, as: as)
    end

    def post(resource_name, path, as: nil)
      @method_definitions << MethodDefinition::Post.new(resource_name, path, as: as)
    end

    def patch(resource_name, path, as: nil)
      @method_definitions << MethodDefinition::Patch.new(resource_name, path, as: as)
    end

    def delete(resource_name, path, as: nil)
      @method_definitions << MethodDefinition::Delete.new(resource_name, path, as: as)
    end

    module MethodDefinition
      class HttpVerb
        attr_reader :name

        def initialize(name, path, as: nil)
          @name, @path, @method_name, @aliases = name, path, as, (as ? [] : nil)
          @path = ->(){ path } if path.is_a?(String)
        end

        def parameter_signature
          raise NotImplementedError
        end

        def method_name
          @method_name
        end

        def variable_name_for_body
          raise NotImplementedError
        end

        def path
          args = @path.parameters.select{|param| param.first == :req }.map{|req| "\#{#{req.last}}" }
          @path.call(*args)
        end

        def parameters
          @path.parameters.select{|param| param.first == :req }.map(&:last)
        end

        def aliases
          @aliases
        end
      end

      class Get < HttpVerb
        def verb
          :get
        end

        def parameter_signature
          "#{parameters.join(', ')}#{', ' if !parameters.empty?}"
        end

        def method_name
          super || "#{verb}_#{name}"
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

        def parameter_signature
          "#{parameters.join(", ")}#{", " if !parameters.empty?}body, "
        end

        def method_name
          super || "#{verb}_#{name}"
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

        def parameter_signature
          "#{parameters.join(", ")}#{", " if !parameters.empty?}body, "
        end

        def method_name
          super || "#{verb}_#{name}"
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

        def parameter_signature
          "#{parameters.join(", ")}#{", " if !parameters.empty?}"
        end

        def method_name
          super || "#{verb}_#{name}"
        end

        def variable_name_for_body
          'nil'
        end

        def aliases
          super || ["destroy_#{name}"]
        end
      end
    end

    private_constant :MethodDefinition
  end

  private_constant :ApiClientBuilder, :DslContext
end
