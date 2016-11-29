require 'test_helper'
require 'examples/api_client'

# This loads the file `tmp/api_client.rb`
require 'api_client'

class ApiClientTest < Minitest::Test
  def setup
    stub_request(:any, /http:\/\/example\.org\/*/)

    @client = ApiClient.new('http://example.org')
  end

  def test_get_all_resources
    @client.get_users(query: {page: 1})

    assert_requested :get, "http://example.org/api/v2/users?page=1",
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  end

  def test_json_response
    response_json = [{ name: 'Yuki' }, { name: 'Matz' }].to_json
    stub_request(:any, /http:\/\/example\.org\/*/).to_return(body: response_json, headers: { 'Content-Length' => 42 })

    response = @client.get_users(query: {page: 1})

    assert_equal ["42"], response.headers['content-length']
    assert_equal 2, response.json.size

    if RUBY_VERSION > '2.2.0'
      users = ObjectMapper.new({}).convert(response.json, to: Array(ApiClient::User))

      assert_equal 'Yuki', users[0].name
      assert_equal 'Matz', users[1].name
    else
      assert_equal 'Yuki', response.json[0]['name']
      assert_equal 'Matz', response.json[1]['name']
    end
  end

  def test_get_all_resources_with_custom_header
    @client.get_users(query: {page: 1}, headers: {'Accept' => '*/*', 'Content-Type' => ''})

    assert_requested :get, "http://example.org/api/v2/users?page=1",
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  end

  def test_get_single_resource
    @client.get_user(1, query: {page: 1})

    assert_requested :get, "http://example.org/api/v2/users/1?page=1",
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  end

  def test_head
    response = @client.head_users

    assert_requested :head, "http://example.org/api/v2/users",
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}

    assert_nil response.body
  end

  def test_post_single_resource
    @client.post_user(name: 'Yuki')

    assert_requested :post, "http://example.org/api/v2/users",
                     body: '{"name":"Yuki"}',
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  end

  def test_patch_single_resource
    @client.patch_user(1, name: 'Yuki')

    assert_requested :patch, "http://example.org/api/v2/users/1",
                     body: '{"name":"Yuki"}',
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  end

  def test_put_single_resource
    @client.put_user(1, name: 'Yuki')

    assert_requested :put, "http://example.org/api/v2/users/1",
                     body: '{"name":"Yuki"}',
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  end

  def test_delete_single_resource
    @client.delete_user(1)

    assert_requested :delete, "http://example.org/api/v2/users/1",
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  end

  def test_options
    @client.options_users

    assert_requested :options, "http://example.org/api/v2/users",
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  end

  def test_as_option_oevrrides_method_name
    assert !@client.respond_to?(:get_authentication), 'The default method should not be defined when the :as option is given'

    @client.authentication
    assert_requested :get, "http://example.org/authentication",
                     headers: {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
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
