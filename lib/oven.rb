require "oven/version"
require "oven/http_statuses"
require "oven/refinements"
require "oven/extension_configurers"
require "oven/dsl_context"
require "oven/builders"

module Oven
  using Patches::StringExt

  @@extensions = [ ExceptionConfigurer.new ]

  def self.register_extension(extension)
    @@extensions << extension
  end

  @@format_mapping = { json: JsonConfigurer }

  def self.register_format(format_type, format_configurer)
    @@format_mapping[format_type.downcase.to_sym] = format_configurer
  end

  def self.bake(full_name, destination: './', object_mapping: nil, &block)
    name_declaration = full_name.to_s
                       .deconstantize
                       .split("::")
                       .map(&Namespace.method(:new)) << ClientName.new(full_name.to_s.demodulize)

    context = DslContext.new(@@extensions.dup, @@format_mapping.dup)
    context.instance_eval(&block)

    if object_mapping
      PoroGenerator.new(object_mapping, name_declaration, destination).generate
      context.extensions << ModelsConfigurer.new(object_mapping)
      context.extensions << ObjectMapperConfigurer.new(context.method_definitions)
    end

    context.extensions.each {|extension| context.configure(extension) }

    ApiClientBuilder.new(name_declaration, destination, context).generate
  end

  class Namespace < String
    def type;       'module' end
    def namespace?; true     end
  end

  class ClientName < String
    def type;       'class' end
    def namespace?; false   end
  end

  private_constant :Namespace, :ClientName
end
