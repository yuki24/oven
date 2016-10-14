require "oven/version"
require "oven/http_statuses"
require "oven/refinements"
require "oven/dsl_context"
require 'erb'
require 'fileutils'

module Oven
  def self.bake(client_name, destination: './', &block)
    ApiClientBuilder.new(client_name, destination, &block).generate
  end

  class ApiClientBuilder
    using Patches::Underscore

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
      FileUtils.mkdir_p("#{destination}/#{client_name.underscore}")
      TEMPLATES.each do |path, template|
        code = ERB.new(template, nil, '-').result(binding)
        path = File.join(destination, "#{client_name.underscore}#{path}")
        File.write(path, code)
      end
    end

    def method_definitions() dsl_context.method_definitions end
    def interceptors()       dsl_context.interceptors end
    def observers()          dsl_context.observers end

    private

    def dsl_context
      @dsl_context ||= begin
                         context = DslContext.new
                         context.instance_eval(&@block)
                         context
                       end
    end
  end

  private_constant :ApiClientBuilder
end
