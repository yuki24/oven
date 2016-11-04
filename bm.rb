require 'json'

DATA = <<-JSON
{
  "products": [
    { "id": 1, "name": "Yuki" }
  ],
  "_links": {
    "self": { "href": "https://example.org/" }
  }
}
JSON

class ProductCollection
  attr_reader :products, :_links
  def initialize(products: nil, _links: nil)
    @products, @_links = products, _links
  end
end
class Product
  attr_reader :id, :name
  def initialize(id: nil, name: nil)
    @id, @name = id, name
  end
end
class Links
  attr_reader :self
  def initialize(self: nil)
    @self = binding.local_variable_get(:self)
  end
end

MAPPING = {
  ProductCollection => { products: Array(Product), _links: Links },
  Product => { id: Integer, name: String },
  Links => { self: Hash }
}

class ObjectMapper
  def initialize(mapping)
    @mapping = mapping.dup
    @mapping.default = {}
  end

  def map_recursively(result, klass)
    if result.is_a?(Array)
      result.map! {|element| map_recursively(element, klass.first) }
    elsif result.is_a?(Hash) && klass != Hash
      result.each do |key, value|
        result[key] = map_recursively(value, @mapping[klass][key] || value.class)
      end

      klass.new(result)
    else
      result
    end
  end
end

require 'minitest'
require 'minitest/autorun'

class ObjectMapperTest < Minitest::Test
  def setup
    @mapper = ObjectMapper.new(MAPPING)
    @hash = JSON.parse(DATA, symbolize_names: true)
  end

  def test_object_mapepr
    collection = @mapper.map_recursively(@hash, ProductCollection)

    assert_equal 1,      collection.products[0].id
    assert_equal "Yuki", collection.products[0].name
    assert_equal "https://example.org/", collection._links.self[:href]
  end
end

MAPPER = ObjectMapper.new(MAPPING)

require 'benchmark/ips'
Benchmark.ips do |x|
  x.report("Just Parsing") { JSON.parse(DATA, symbolize_names: true) }
  x.report("Parsing + OM") { MAPPER.map_recursively(JSON.parse(DATA, symbolize_names: true), ProductCollection) }
  x.compare!
end

require 'memory_profiler'
hash = JSON.parse(DATA, symbolize_names: true)
executable = proc { MAPPER.map_recursively(hash, ProductCollection) }
MemoryProfiler.report { 100000.times(&executable) }.pretty_print
