# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')({
  globals: off
})

basic_auth = require 'basic-auth'
valid_key = conf.api.auth

CacheLoop = require 'taky-cache-loop'

keys_cache = new CacheLoop {
  key: 'mkay:apikeys'
  interval: '10 seconds'
  use: ((cb) ->
    if !conf.mongo then return cb null, []

    await col('apikeys').find {active:on}, defer e,r

    if !e and r?.length
      cb null, (_.map r, (x) -> x.key)
    else
      cb null, []
  )
}

internal = {}

internal.middleware = (req,res,next) ->
  ignore = [
    '/_/'
  ]

  for x in ignore
    return next() if req.path.startsWith(x)

  if req.path in ___public_routes
    if !process.env.SILENCE
      log.warn 'AUTH_MIDDLEWARE', "Allowing request #{req.method} #{req.path} (public route)"
    return next()

  forbid = ->
    req.no_stack = yes
    res.status 403
    return next new Error 'Unauthorized'

  {user, pass} = basic_auth(req) || ({
    user: req.headers['x-auth-username']
    pass: req.headers['x-auth-password']
  })

  pass = user if user and !pass

  if pass and pass.contains('token:')
    pass = pass.split(':').pop()

  if !pass then return forbid()

  try
    return next() if pass in keys_cache.val()

  if !pass or pass isnt valid_key
    return forbid()

  next()

module.exports = internal


