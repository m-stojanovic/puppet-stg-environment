#
# array_index.rb
#

# TODO(Krzysztof Wilczynski): We need to add support for regular expression ...
# TODO(Krzysztof Wilczynski): Support for strings and hashes too ...

module Puppet::Parser::Functions
  newfunction(:array_index, :type => :rvalue, :doc => <<-EOS
This function determines the index of a variable if it is a member of an array.

*Examples:*

    member(['a','b'], 'b')

Would return: 2

    member(['a','b'], 'c')

Would return: undef
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "member(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    array = arguments[0]

    unless array.is_a?(Array)
      raise(Puppet::ParseError, 'member(): Requires array to work with')
    end

    item = arguments[1]

    raise(Puppet::ParseError, 'member(): You must provide item ' +
      'to search for within array given') if item.empty?

    result = array.index(item)

    return result
  end
end

# vim: set ts=2 sw=2 et :
