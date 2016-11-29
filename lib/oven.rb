require "oven/version"
require "oven/http_statuses"
require "oven/refinements"
require "oven/extension_configurers"
require "oven/dsl_context"

require 'forwardable'
require 'erb'
require 'fileutils'

module Oven
  @@extensions = [ ExceptionConfigurer.new ]

  def self.register_extension(extension)
    @@extensions << extension
  end

  @@format_mapping = { json: JsonConfigurer }

  def self.register_format(format_type, format_configurer)
    @@format_mapping[format_type.downcase.to_sym] = format_configurer
  end

  def self.bake(client_name, destination: './', &block)
    context = DslContext.new(@@extensions.dup, @@format_mapping.dup)
    context.instance_eval(&block)
    context.extensions.each {|extension| context.configure(extension) }

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

        File.write(path, code)
      end
    end
  end

  private_constant :ApiClientBuilder
end
