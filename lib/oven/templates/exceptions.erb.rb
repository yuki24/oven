class <%= client_name %>
  class APIError < StandardError; end
  class NetworkError < APIError; end

  class HttpError < APIError
    attr_reader :response

    def initialize(message, response)
      super(message)
      @response = response
    end
  end

  class ClientError < HttpError; end

  <%- CLIENT_ERROR_STATUSES.each do |status, error_name| -%>
  class <%= error_name.tr(" ", "").ljust(27) %> < ClientError; end # status: <%= status %>
  <%- end -%>

  class ServerError < HttpError; end

  <%- SERVER_ERROR_STATUSES.each do |status, error_name| -%>
  class <%= error_name.tr(" ", "").ljust(29) %> < ServerError; end # status: <%= status %>
  <%- end -%>

  STATUS_TO_EXCEPTION_MAPPING = {
  <%- CLIENT_ERROR_STATUSES.merge(SERVER_ERROR_STATUSES).each do |status, error| -%>
    '<%= status %>' => <%= error.tr(" ", "") %>,
  <%- end -%>
  }.freeze

  class ResponseHandler
    def received_response(response)
      error = STATUS_TO_EXCEPTION_MAPPING[response.code]
      raise error.new("Receieved an error response: #{response.code} #{response.code_type.to_s.gsub(/^Net::HTTP/, "")}", response) if error
      response
    end
  end

  private_constant :ResponseHandler
end
