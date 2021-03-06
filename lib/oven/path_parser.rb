#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.14
# from Racc grammer file "".
#

require 'racc/parser.rb'

require 'oven/path_parser/parser_extension'
module Oven
  class PathParser < Racc::Parser
##### State transition tables begin ###

racc_action_table = [
     6,     8,     7,     6,     8,     7,     9,    11 ]

racc_action_check = [
     0,     0,     0,     2,     2,     2,     1,     9 ]

racc_action_pointer = [
    -2,     6,     1,   nil,   nil,   nil,   nil,   nil,   nil,     7,
   nil,   nil ]

racc_action_default = [
    -9,    -9,    -2,    -3,    -4,    -5,    -6,    -7,    -8,    -9,
    -1,    12 ]

racc_goto_table = [
     1,   nil,    10 ]

racc_goto_check = [
     1,   nil,     1 ]

racc_goto_pointer = [
   nil,     0,   nil,   nil,   nil,   nil ]

racc_goto_default = [
   nil,   nil,     2,     3,     4,     5 ]

racc_reduce_table = [
  0, 0, :racc_error,
  2, 6, :_reduce_1,
  1, 6, :_reduce_2,
  1, 7, :_reduce_none,
  1, 7, :_reduce_none,
  1, 7, :_reduce_none,
  1, 8, :_reduce_6,
  1, 9, :_reduce_7,
  1, 10, :_reduce_8 ]

racc_reduce_n = 9

racc_shift_n = 12

racc_token_table = {
  false => 0,
  :error => 1,
  :SLASH => 2,
  :LITERAL => 3,
  :SYMBOL => 4 }

racc_nt_base = 5

racc_use_result_var = false

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "SLASH",
  "LITERAL",
  "SYMBOL",
  "$start",
  "expressions",
  "expression",
  "slash",
  "symbol",
  "literal" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

module_eval(<<'.,.,', 'path_parser.y', 6)
  def _reduce_1(val, _values)
     val.flatten 
  end
.,.,

module_eval(<<'.,.,', 'path_parser.y', 7)
  def _reduce_2(val, _values)
     val.first 
  end
.,.,

# reduce 3 omitted

# reduce 4 omitted

# reduce 5 omitted

module_eval(<<'.,.,', 'path_parser.y', 15)
  def _reduce_6(val, _values)
     Slash.new('/') 
  end
.,.,

module_eval(<<'.,.,', 'path_parser.y', 18)
  def _reduce_7(val, _values)
     Symbol.new(val.first) 
  end
.,.,

module_eval(<<'.,.,', 'path_parser.y', 21)
  def _reduce_8(val, _values)
     Literal.new(val.first) 
  end
.,.,

def _reduce_none(val, _values)
  val[0]
end

  end   # class PathParser
  end   # module Oven
