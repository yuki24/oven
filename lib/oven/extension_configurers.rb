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

  class ObjectMapperConfigurer
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

  private_constant :ApiClientConfigurer, :ExceptionConfigurer, :JsonConfigurer, :ObjectMapperConfigurer
end
