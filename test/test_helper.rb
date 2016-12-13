$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../tmp', __FILE__)
require 'oven'

require 'minitest/autorun'
require 'minitest/pride'
require 'webmock/minitest'
require 'bundler'
Bundler.require
