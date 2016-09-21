# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')({
  globals: off
})

require 'date-utils'

cache = require 'memory-cache'
coffee = require 'iced-coffee-script'

module.exports = helpers = {}

helpers.load = ((url) ->
  if url.substr(-3) is '.js'
    return "<script src=\"#{url}\"></script>"
  if url.substr(-4) is '.css'
    return "<link href=\"#{url}\" rel=\"stylesheet\">"
  if url.match '.js'
    "<script src=\"#{url}\"></script>"
  else
    "<link href=\"#{url}\" rel=\"stylesheet\">"
)

cache_block_helper = ((prefix,helper) ->
  (args...) =>

    # disable cache
    return result = helper(args...)

    input = args[0]?.fn(this)
    if cached = cache.get("#{prefix}:#{input}")
      cached
    else
      result = helper(args...)
      cache.put("#{prefix}:#{input}", result)
      result
)

helpers.coffee = helpers.iced = cache_block_helper 'coffee', (script) ->
  args = arguments
  ret = do ->
    if src = args['0']?.fn()
      js = coffee.compile src, {runtime:'inline'}
      return "<script>#{js}</script>"
    ''
  ret

helpers.nofollow = -> "<meta name=\"robots\" content=\"noindex,nofollow\">"

helpers.percent = ((part,whole,keep_order) ->
  if !part or part is 0 then return '0.00%'
  if !whole or whole is 0 then return '0.00%'

  order = yes
  order = no if not keep_order

  part = parseInt part
  whole = parseInt whole

  if part > whole
    if !order
      [part,whole] = [whole,part]

  div = (part/whole)*100
  (div.toFixed 2) + '%'
)

helpers.trunc = ((str,length) ->
  if str.length > length
    temp = str.substr(0,length)
  else
    str
)

helpers.date = (unix) ->
  d = new Date unix * 1000
  d.toFormat 'MM/DD/YYYY'

helpers.min_date = (str) ->
  d = new Date str
  d.toFormat 'M/D'

helpers.full_date = (str) ->
  d = new Date str
  d.toFormat 'M/D/YYYY'

helpers.upper = (str) -> try str.toUpperCase() catch str
helpers.lower = (str) -> try str.toLowerCase() catch str

helpers.size = ((obj) ->
  try
    return _.size(obj)
  catch
    0
)

helpers.yn = (bool) -> (if bool then return "Yes" else "No")

helpers.join = ((arr,delim) ->
  if _.type(arr) is 'string'
    arr = arr.split ','
  arr.join(delim)
)

helpers.stringify = (str) -> JSON.stringify(str)

# merge wegweg
for x in [
  'ucfirst'
  'ucwords'
  'uri_title'
  'b64_encode'
  'md5'
  'nt'
]
  helpers[x] = _[x] if _[x]?

# merge swag
helpers[k] = v for k,v of (require('./swag.js').helpers)

