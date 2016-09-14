exports.registerHelpers = (hbs) ->
  """
  Register 'ifCond': a helper to handle variable comparisons
  Example: {{#ifCond var1 '==' var2}}
  """
  hbs.registerHelper 'ifCond', (v1, operator, v2, options) ->
    switch operator
      when '==', '===', 'is'
        return if v1 is v2 then options.fn this else options.inverse this
      when '<'
        return if v1 < v2 then options.fn this else options.inverse this
      when '<='
        return if v1 <= v2 then options.fn this else options.inverse this
      when '>'
        return if v1 > v2 then options.fn this else options.inverse this
      when '>='
        return if v1 >= v2 then options.fn this else options.inverse this
      when '&&', 'and'
        return if v1 and v2 then options.fn this else options.inverse this
      when '||', 'or'
        return if v1 or v2 then options.fn this else options.inverse this
      else
        return options.inverse this