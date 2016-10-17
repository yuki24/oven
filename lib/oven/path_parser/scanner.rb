require "strscan"

module Oven
  class PathScanner # :nodoc:
    def initialize(path_str)
      @ss = StringScanner.new(path_str)
    end

    def next_token
      return if @ss.eos?

      scan
    end

    private

    def scan
      case
      # /
      when text = @ss.scan(/\//)
        [:SLASH, text]
      when text = @ss.scan(/(?<!\\):\w+/)
        [:SYMBOL, text]
      when text = @ss.scan(/(?:[\w%\-~!$&'*+,;=@]|\\:|\\\(|\\\))+/)
        [:LITERAL, text.tr('\\', "")]
      # any char
      when text = @ss.scan(/./)
        [:LITERAL, text]
      end
    end
  end
end
