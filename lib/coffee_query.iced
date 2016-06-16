# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')({
  globals: off
})

vm = require 'vm'
coffee = require 'iced-coffee-script'

# convert coffee string to object
module.exports = coffee_query = {}

coffee_query.convert = (str) ->
  res = {}

  str = str.trim()
  str = '{' + str + '}' if !str.startsWith('{')

  res.original = str

  try
    compiled = coffee.compile "_tmp_obj = #{str}", bare:yes

    sandbox = _tmp_obj:{}
    vm.runInNewContext compiled, sandbox

    if _.type(sandbox) is 'object'
      res.ok = yes
      res.valid = yes

      try
        for k,v of sandbox._tmp_obj
          if _.type(v) is 'regexp'
            continue if v.toString().contains('//')
            v = v.toString()
            if v.startsWith('/')
              v = v.substr(1)
            [expression,flags] = v.split('/')
            v = new RegExp(expression, flags ? '')
            sandbox._tmp_obj[k] = v

      res.result = sandbox._tmp_obj
    else
      res.ok = no
      res.valid = no

  catch
    res.ok = no
    res.valid = no

  res

coffee_query.parse_extra_filters = (req,res,next) ->
  req.extra_filters = {}

  filter = {}

  for k,v of req.query
    if k.startsWith('filter.')
      name = k.substr("filter.".length)
      tmp = coffee_query.convert v

      if tmp.ok
        filter[k] = v for k,v of tmp.result

  if _.size(filter)
    req.extra_filters = filter
      
  next()

coffee_query.middleware = (req,res,next) ->
  inp = req.query.filter ? req.body.filter
  sort_inp = req.query.sort ? req.body.sort

  req.coffee_filter = null
  req.coffee_filter_sort = null

  if inp and _.type(inp) is 'string'
    r = coffee_query.convert inp.trim()
    if r.result
      req.coffee_filter = r.result
      res.locals.coffee_filter = inp.trim()

  if sort_inp and _.type(sort_inp) is 'string'
    r = coffee_query.convert sort_inp.trim()
    if r.result
      req.metadata.sort = req.coffee_filter_sort = r.result
      res.locals.coffee_filter_sort = sort_inp.trim()

  # append extra filters if they exist
  if req.extra_filters? and _.size(req.extra_filters)
    req.coffee_filter = {} if !req.coffee_filter
    req.coffee_filter[k] = v for k,v of req.extra_filters

  req.metadata.filter = req.coffee_filter ? {}
      
  next()

###
tests = [
  "{_id:'one','userdata.geo_country':'US'}"
  "invalid"
  null
]

for x in tests
  log convert x

{ ok: true,
  valid: true,
  result: { _id: 'one', 'userdata.geo_country': 'US' } }
{ ok: false, valid: false }
{ ok: false, valid: false }
###

