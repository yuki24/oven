require 'forwardable'
require 'erb'
require 'fileutils'
require 'yaml'

module Oven
  module NameDeclarationExt
    refine Array do
      alias client_name last

      def namespace_or_client_name
        size == 1 ? self : select(&:namespace?)
      end
    end
  end

  class ApiClientBuilder
    using Patches::StringExt
    using NameDeclarationExt

    attr_reader :name_declaration, :destination, :dsl_context

    extend Forwardable
    delegate [:method_definitions, :interceptors, :observers, :requires] => :dsl_context

    def initialize(name_declaration, destination, context)
      @name_declaration, @destination, @dsl_context = name_declaration, destination, context
    end

    def generate
      FileUtils.mkdir_p(destination)
      ([ApiClientConfigurer.new] + dsl_context.extensions).each do |extension|
        template = open(extension.template_path).read
        path     = extension.filename(destination, name_declaration.client_name.underscore)
        code     = ERB.new(template, trim_mode: '-').result(binding)

        puts "generated: #{path}"
        File.write(path, code)
      end
    end
  end

  # PORO stands for Plain Old Ruby Object: https://en.wikipedia.org/wiki/Plain_Old_Java_Object
  class PoroGenerator
    using Patches::StringExt
    using NameDeclarationExt

    REVERSED_KEYWORD_MAP = {
      'self'   => 'binding.local_variable_get(:self)',
      'class'  => 'binding.local_variable_get(:class)',
      'end'    => 'binding.local_variable_get(:end)',
      'if'     => 'binding.local_variable_get(:if)',
      'unless' => 'binding.local_variable_get(:unless)'
    }.freeze

    PORO_TEMPLATE = open("#{__dir__}/templates/poro.rb.erb").read
    ERB_PROCESSOR = -> (class_name, attributes, name_declaration, reserved_keyword_map) {
                      ERB.new(PORO_TEMPLATE, trim_mode: '-').result(binding)
                    }

    def initialize(filepath, name_declaration, destination)
      @data             = YAML.load_file(filepath)
      @destination      = destination
      @name_declaration = name_declaration
    end

    def generate
      root_path = File.join(@destination, 'models')

      FileUtils.mkdir_p(root_path)
      @data.each do |class_name, attributes|
        code = ERB_PROCESSOR.call(class_name, attributes.keys, @name_declaration, REVERSED_KEYWORD_MAP)
        path = File.join(root_path, "#{class_name.underscore}.rb")

        puts "generated: #{path}"
        File.write(path, code)
      end
    end
  end

  private_constant :NameDeclarationExt, :ApiClientBuilder, :PoroGenerator
end
