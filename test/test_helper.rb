$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../tmp', __FILE__)
require 'oven'

require 'minitest/autorun'
require 'webmock/minitest'
require 'purdytest'
require 'bundler'
Bundler.require
