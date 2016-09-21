# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')({
  globals: no
})

# render macros in a string
module.exports = macros = (inp,items...) ->
  str = _.clone inp

  valid = {}

  do_escape = yes

  if _.type(_.last(items)) is 'boolean'
    do_escape = items.pop()

  if items?.length
    for obj in items
      try
        for k,v of obj
          valid[k] ?= v

    try
      str = str.replace /{{([\s\S]+?)}}/g, (a,b) ->
        if hit = valid[b]
          if do_escape
            return escape hit
          else
            return hit
        ''
    catch
      str

  str

