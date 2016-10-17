class Oven::PathParser
  options no_result_var
token SLASH LITERAL SYMBOL

rule
  expressions
    : expression expressions  { val.flatten }
    | expression              { val.first }
    ;
  expression
    : slash
    | symbol
    | literal
    ;
  slash
    : SLASH              { Slash.new('/') }
    ;
  symbol
    : SYMBOL             { Symbol.new(val.first) }
    ;
  literal
    : LITERAL            { Literal.new(val.first) }
    ;

end

---- header
require 'oven/path_parser/parser_extension'
