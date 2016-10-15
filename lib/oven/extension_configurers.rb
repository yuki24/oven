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

  private_constant :ApiClientConfigurer, :ExceptionConfigurer, :JsonConfigurer
end
