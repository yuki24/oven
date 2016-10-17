require 'oven/path_parser/scanner'
require 'oven/path_parser/nodes'
require 'oven/path_parser/path_ast'

module Oven
  class PathParser < Racc::Parser # :nodoc:
    include Oven::Nodes

    def self.parse(path_str)
      scanner = PathScanner.new(path_str)
      parser  = PathParser.new(scanner)

      PathAst.new(parser.parse)
    end

    def initialize(scanner)
      @scanner = scanner
    end

    alias parse do_parse

    def next_token
      @scanner.next_token
    end
  end
end
