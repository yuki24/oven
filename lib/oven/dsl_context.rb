module Oven
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

  private_constant :DslContext
end
