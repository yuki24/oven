module Oven
  class ApiClientConfigurer
    def filename(path, client_filename)
      File.join(path, "#{client_filename}.rb")
    end

    def template_path
      "#{__dir__}/templates/client.rb.erb"
    end
  end

  class ExceptionConfigurer
    def filename(path, client_filename)
      File.join(path, 'exceptions.rb')
    end

    def template_path
      "#{__dir__}/templates/exceptions.rb.erb"
    end

    def configure_observers(observers)
      observers << 'ResponseHandler'
    end

    def configure_requires(requires)
      requires << 'exceptions'
    end
  end

  class JsonConfigurer
    def filename(path, client_filename)
      File.join(path, 'json_handler.rb')
    end

    def template_path
      "#{__dir__}/templates/json.rb.erb"
    end

    def configure_interceptors(interceptors)
      interceptors << 'JsonSerializer'
    end

    def configure_observers(observers)
      observers << 'JsonDeserializer'
    end

    def configure_requires(requires)
      requires << 'json_handler'
    end
  end

  class ModelsConfigurer
    PRIMITIVE_CLASSES = [
      'Integer',
      'String',
      'Boolean',
      'Date',
      'Time',
      'DateTime',
      'Hash',
      'Array(Integer)',
      'Array(String)',
      'Array(Boolean)',
      'Array(Date)',
      'Array(Time)',
      'Array(DateTime)',
      'Array(Hash)'
    ].freeze

    def initialize(object_mapping_path)
      @object_mapping_path = object_mapping_path
    end

    def primitive_classes
      PRIMITIVE_CLASSES
    end

    def object_mapping
      @object_mapping ||= YAML.load_file(@object_mapping_path)
    end

    def class_names
      object_mapping.keys
    end

    def filename(path, client_filename)
      File.join(path, 'models.rb')
    end

    def template_path
      "#{__dir__}/templates/models.rb.erb"
    end

    def configure_requires(requires)
      requires << 'models'
    end
  end

  class ObjectMapperConfigurer
    attr_reader :method_definitions

    def initialize(method_definitions)
      @method_definitions = method_definitions
    end

    def filename(path, client_filename)
      File.join(path, 'object_mapping.rb')
    end

    def template_path
      "#{__dir__}/templates/object_mapping.rb.erb"
    end

    def configure_observers(observers)
      observers << 'ObjectConverter'
    end

    def configure_requires(requires)
      requires << 'object_mapping'
    end
  end

  class MinitestConfigurer
    def filename(path, client_filename)
      FileUtils.mkdir_p("#{path}/test")
      File.join(path, ('../' * path.split('/').size), 'test', "#{client_filename}_test.rb")
    end

    def template_path
      "#{__dir__}/templates/minitest.rb.erb"
    end
  end

  private_constant :ApiClientConfigurer, :ExceptionConfigurer, :JsonConfigurer, :ObjectMapperConfigurer,
                   :ModelsConfigurer, :MinitestConfigurer
end
