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
      @method_definitions << Get.new(resource_name, path, as: as)
    end

    def post(resource_name, path, as: nil)
      @method_definitions << Post.new(resource_name, path, as: as)
    end

    def patch(resource_name, path, as: nil)
      @method_definitions << Patch.new(resource_name, path, as: as)
    end

    def delete(resource_name, path, as: nil)
      @method_definitions << Delete.new(resource_name, path, as: as)
    end

    class HttpVerb
      using Patches::ToProc
      attr_reader :name, :method_name, :aliases

      def initialize(name, path, as: nil)
        @name        = name
        @path        = path.to_proc
        @method_name = as || "#{verb}_#{name}"
        @aliases     = as ? [] : nil
      end

      def verb
        raise NotImplementedError
      end

      def variable_name_for_body
        raise NotImplementedError
      end

      def path
        @path.call(* parameters.reject{|req| req == :body }.map{|req| "\#{#{req}}" })
      end

      def parameters
        @path.parameters.select{|param| param.first == :req }.map(&:last)
      end

      def parameter_signature
        parameters.join(", ")
      end
    end

    class Get < HttpVerb
      def verb
        :get
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

      def parameters
        super.dup << :body
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

      def parameters
        super.dup << :body
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

      def variable_name_for_body
        'nil'
      end

      def aliases
        super || ["destroy_#{name}"]
      end
    end

    private_constant :HttpVerb, :Get, :Post, :Patch, :Delete
  end

  private_constant :DslContext
end
