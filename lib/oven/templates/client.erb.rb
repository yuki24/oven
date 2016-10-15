# -*- frozen-string-literal: true -*-
require 'net/http'
<%- requires.each do |_require| -%>
require '<%= File.join([namespace, _require].compact) %>'
<%- end -%>

class <%= client_name %>
  attr_reader :domain, :proxy_addr, :proxy_port, :proxy_user, :proxy_password

  def initialize(domain, proxy_addr: nil, proxy_port: nil, proxy_user: nil, proxy_password: nil)
    @domain, @proxy_addr, @proxy_port, @proxy_user, @proxy_password, @interceptors, @observers =
      domain, proxy_addr, proxy_port, proxy_user, proxy_password, [], []

    <%- interceptors.each do |interceptor| -%>
    register_interceptor(<%= interceptor %>.new)
    <%- end -%>
    <%- observers.each do |observer| -%>
    register_observer(<%= observer %>.new)
    <%- end -%>
  end

  def register_interceptor(interceptor)
    @interceptors << interceptor
  end

  def register_observer(observer)
    @observers << observer
  end
  <%- method_definitions.each do |definition| %>
  def <%= definition.method_name %>(<%= definition.parameter_signature %><%= ', ' if !definition.parameters.empty? %>query: {}, headers: {}, **options)
    request(Net::HTTP::<%= definition.class.name.split("::").last %>, uri("<%= definition.path %>", query), <%= definition.variable_name_for_body %>, headers, options)
  end
  <% definition.aliases.each {|name| %>alias <%= name %> <%= definition.method_name %><% } %>
  <%- end %>
  private

  DEFAULT_OPTIONS = {
    ca_file: nil,
    ca_path: nil,
    cert: nil,
    cert_store: nil,
    ciphers: nil,
    close_on_empty_response: nil,
    key: nil,
    open_timeout: nil,
    read_timeout: nil,
    ssl_timeout: nil,
    ssl_version: nil,
    use_ssl: nil,
    verify_callback: nil,
    verify_depth: nil,
    verify_mode: nil
  }.freeze

  HTTPS = 'https'.freeze

  def request(request_class, uri, body, headers, options = {})
    uri, body, headers, options = @interceptors.reduce([uri, body, headers, DEFAULT_OPTIONS.merge(options)]) {|r, i| i.before_request(*r) }

    begin
      response = Net::HTTP.start(uri.host, uri.port, proxy_addr, proxy_port, proxy_user, proxy_password, options, use_ssl: (uri.scheme == HTTPS)) do |http|
        http.request request_class.new(uri, headers), body
      end
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      raise NetworkError, "A network error occurred: #{e.class} (#{e.message})"
    end

    @observers.reduce(response) {|r, o| o.received_response(r) }
  end

  def uri(path, query = {})
    uri = URI.join(domain, path)
    uri.query = URI.encode_www_form(query) if !query.empty?
    uri
  end
end
