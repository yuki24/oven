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
end
