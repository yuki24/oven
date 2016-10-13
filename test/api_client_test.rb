require 'test_helper'
require 'examples/api_client'

require_relative '../tmp/api_client'

class ApiClientTest < Minitest::Test
  def setup
    stub_request(:any, /http:\/\/example\.org\/*/)

    @client = ApiClient.new('http://example.org')
  end

  def test_get_all_resources
    @client.get_users(query_params: {page: 1})

    assert_requested :get, "http://example.org/api/v2/users?page=1",
                     headers: {'Accept' => 'application/json', 'Content-Type': 'application/json'}
  end

  def test_get_all_resources_with_custom_header
    @client.get_users(query_params: {page: 1}, headers: {'Accept' => '*/*', 'Content-Type': ''})

    assert_requested :get, "http://example.org/api/v2/users?page=1",
                     headers: {'Accept' => 'application/json', 'Content-Type': 'application/json'}
  end

  def test_get_single_resource
    @client.get_user(1, query_params: {page: 1})

    assert_requested :get, "http://example.org/api/v2/users/1?page=1",
                     headers: {'Accept' => 'application/json', 'Content-Type': 'application/json'}
  end

  def test_post_single_resource
    @client.post_user(name: 'Yuki')

    assert_requested :post, "http://example.org/api/v2/users",
                     body: '{"name":"Yuki"}',
                     headers: {'Accept' => 'application/json', 'Content-Type': 'application/json'}
  end

  def test_patch_single_resource
    @client.patch_user(1, name: 'Yuki')

    assert_requested :patch, "http://example.org/api/v2/users/1",
                     body: '{"name":"Yuki"}',
                     headers: {'Accept' => 'application/json', 'Content-Type': 'application/json'}
  end

  def test_delete_single_resource
    @client.delete_user(1)

    assert_requested :delete, "http://example.org/api/v2/users/1",
                     headers: {'Accept' => 'application/json', 'Content-Type': 'application/json'}
  end

  def test_as_option_oevrrides_method_name
    assert !@client.respond_to?(:get_authentication), 'The default method should not be defined when the :as option is given'

    @client.authentication
    assert_requested :get, "http://example.org/authentication",
                     headers: {'Accept' => 'application/json', 'Content-Type': 'application/json'}
  end

  def test_exception_raises_when_timing_out
    stub_request(:any, /http:\/\/example\.org\/*/).to_timeout

    error = assert_raises(ApiClient::NetworkError) { @client.get_users }

    assert_equal "A network error occurred: Timeout::Error (execution expired)", error.message
  end

  def test_exception_raises_when_bad_request
    stub_request(:any, /http:\/\/example\.org\/*/).to_return(status: 400, body: 'Error')

    error = assert_raises(ApiClient::BadRequest){ @client.get_users }

    message, response = error.message, error.response
    assert_equal "Receieved an error response: 400 BadRequest", message
    assert_equal "400", response.code
    assert_equal "Error", response.body
  end

  def test_exception_raises_when_internal_server_error
    stub_request(:any, /http:\/\/example\.org\/*/).to_return(status: 500, body: 'Error')

    error = assert_raises(ApiClient::InternalServerError){ @client.get_users }

    message, response = error.message, error.response
    assert_equal "Receieved an error response: 500 InternalServerError", message
    assert_equal "500", response.code
    assert_equal "Error", response.body
  end
end
