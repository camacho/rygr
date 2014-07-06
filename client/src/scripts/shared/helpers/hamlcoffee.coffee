# Port of https://github.com/netzpirat/haml_coffee_assets/blob/master/vendor/
# assets/javascripts/hamlcoffee_amd.js.coffee.erb
# Prevents having each individual template module from having to define
# this functionality at the top of their file

# HAML Coffee helper module
#
define ->

  # HAML Coffee html escape function.
  #
  # @param text [String] the text to escape
  # @return [String] the escaped text
  #
  escape: (text) ->
    ('' + text)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/'/g, '&quot;')
      .replace(/'/g, '&#39;')
      .replace(/\//g, '&#47;')

  # HAML Coffee clean value function. Beside just
  # cleaning `null` and `undefined` values, it
  # adds a hidden unicode marker character to
  # boolean values, so that the render time boolean
  # logic can distinguish between real booleans and
  # boolean-like strings.
  #
  # @param text [String] the text to be cleaned
  # @return [String] the cleaned text
  #
  cleanValue: (text) ->
    switch text
      when null, undefined then ''
      when true, false then '\u0093' + text
      else text

  # Preserve newlines in the text
  #
  # @param text [String] the text to preserve
  # @return [String] the preserved text
  #
  preserve: (text) ->
    text.replace /\n/g, '&#x000A;'

  # Find and preserve newlines in the preserving tags
  #
  # @param text [String] the text to preserve
  # @return [String] the preserved text
  #
  findAndPreserve: (text) ->
    tags = 'pre,textarea,abbr'.split(',').join('|')
    regExp = RegExp('<(' + tags + ')>([\\s\\S]*?)<\\/\\1>') g
    text = text.replace(/\r/g, '')
      .replace regExp, (str, tag, content) ->
        "<#{ tag }>#{ @preserve content  }</#{ tag }>"

  # The surround helper surrounds the function output
  # with the start and end string without whitespace in between.
  #
  # @param [String] start the text to prepend to the text
  # @param [String] end the text to append to the text
  # @param [Function] fn the text generating function
  # @return [String] the surrounded text
  #
  surround: (start, end, fn) ->
    start + fn.call(@)?.replace(/^\s+|\s+$/g, '') + end

  # The succeed helper appends text to the function output
  # without whitespace in between.
  #
  # @param [String] end the text to append to the text
  # @param [Function] fn the text generating function
  # @return [String] the succeeded text
  #
  succeed: (end, fn) ->
    fn.call(@)?.replace(/\s+$/g, '') + end

  # The precede helper prepends text to the function output
  # without whitespace in between.
  #
  # @param [String] start the text to prepend to the text
  # @param [Function] fn the text generating function
  # @return [String] the preeceded text
  #
  precede: (start, fn) ->
    start + fn.call(@)?.replace(/^\s+/g, '')

  # Get the HAML template context. This merges the local
  # and the global template context into a new context.
  #
  # @param locals [Object] the local template context
  # @return [Object] the merged context
  #
  context: (locals) -> locals

  # The reference helper creates id and class attributes
  # for an object reference.
  #
  # @param [Object] object the referenced object
  # @param [String] prefix the optional id and class prefix
  # @return [String] the id and class attributes
  #
  reference: (object, prefix) ->
    name = if prefix then prefix + '_' else ''

    if typeof(object.hamlObjectRef) is 'function'
      name += object.hamlObjectRef()
    else
      name += (object.constructor?.name or 'object').replace(/\W+/g, '_')
        .replace(/([a-z\d])([A-Z])/g, '$1_$2').toLowerCase()

    id = (
      if typeof(object.to_key) is 'function'
        object.to_key()
      else if typeof(object.id) is 'function'
        object.id()
      else if object.id
        object.id
      else
        object
    )

    result  = "class='#{ name }'"
    result += " id='#{ name }_#{ id }'" if i
