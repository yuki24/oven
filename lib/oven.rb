require "oven/version"
require "oven/http_statuses"
require "oven/refinements"
require "oven/extension_configurers"
require "oven/dsl_context"

require 'forwardable'
require 'erb'
require 'fileutils'
require 'yaml'

module Oven
  @@extensions = [ ExceptionConfigurer.new ]

  def self.register_extension(extension)
    @@extensions << extension
  end

  @@format_mapping = { json: JsonConfigurer }

  def self.register_format(format_type, format_configurer)
    @@format_mapping[format_type.downcase.to_sym] = format_configurer
  end

  def self.bake(client_name, destination: './', object_mapping: nil, &block)
    context = DslContext.new(@@extensions.dup, @@format_mapping.dup)
    context.instance_eval(&block)
    context.extensions.each {|extension| context.configure(extension) }

    if object_mapping
      PoroGenerator.new(object_mapping, client_name, destination).generate
      context.configure(ObjectMapperConfigurer.new)
    end

    ApiClientBuilder.new(client_name, destination, context).generate
  end

  class ApiClientBuilder
    using Patches::StringExt
    attr_reader :client_name, :destination, :dsl_context

    extend Forwardable
    delegate [:method_definitions, :interceptors, :observers, :requires] => :dsl_context

    def initialize(client_name, destination, context)
      @client_name, @destination, @dsl_context = client_name, destination, context
    end

    def namespace
      client_name.underscore.namespace
    end

    def generate
      filename = File.basename(client_name.underscore)

      FileUtils.mkdir_p(destination)
      ([ApiClientConfigurer.new] + dsl_context.extensions).each do |extension|
        template = open(extension.template_path).read
        path     = extension.filename(destination, filename)
        code     = ERB.new(template, nil, '-').result(binding)

        puts "generated: #{path}"
        File.write(path, code)
      end
    end
  end

  # PORO stands for Plain Old Ruby Object: https://en.wikipedia.org/wiki/Plain_Old_Java_Object
  class PoroGenerator
    using Patches::StringExt

    def initialize(filepath, client_name, destination)
      @data        = YAML.load_file(filepath)
      @destination = destination
      @client_name = client_name
      @namespace   = client_name.deconstantize
      @namespace   = client_name if @namespace.empty?
    end

    def generate
      root_path = File.join(@destination, 'models')

      FileUtils.mkdir_p(root_path)
      @data.each do |class_name, attributes|
        namespaced_classname = [@namespace, class_name].compact.join('::')

        code = ErbContext.new(namespaced_classname, attributes.keys).to_code
        path = File.join(root_path, "#{class_name.underscore}.rb")

        puts "generated: #{path}"
        File.write(path, code)
      end

      models_code = @data.keys.map do |class_name|
        "require '#{File.join([@client_name.underscore.namespace, 'models', class_name.underscore].compact)}'"
      end.join("\n")

      puts "generated: #{root_path}.rb"
      File.write("#{root_path}.rb", models_code)
    end

    class ErbContext
      attr_reader :class_name, :attributes

      PORO_TEMPLATE = open("#{__dir__}/oven/templates/poro.rb.erb").read

      def initialize(class_name, attributes)
        @class_name, @attributes = class_name, attributes
      end

      def to_code
        ERB.new(PORO_TEMPLATE, nil, '-').result(binding)
      end
    end

    private_constant :ErbContext
  end

  private_constant :ApiClientBuilder, :PoroGenerator
end
