_ = require('wegweg')({
  globals: on
  shelljs: on
})

require './lib/globals'
require './lib/startup'

models = require './lib/models'

app = _.app({
  static: off
  body_parser: on
})

app.use ((req,res,next) ->
  if req.real_ip.includes(':ffff:') or req.real_ip.includes('127.0.0.1')
    req.real_ip = '127.0.0.1'
  return next()
)

# allow method override
if conf.allow_http_method_override
  log.warn 'Allowing HTTP method override using `req.query` (`?method=post`)'

  app.use ((req,res,next) ->
    valid_methods = ['post','delete']

    if req.method is 'GET' and req.query.method
      method = req.query.method.toLowerCase().trim()
      return next() if method !in valid_methods

      req.method = method.toUpperCase().trim()

      if method is 'post'
        body = _.clone req.query
        try delete body.method

        req.query = {}
        req.body = body

    next()
  )

app.use (require './lib/api_response').middleware
app.use (require './lib/metadata').middleware

coffee_query = require './lib/coffee_query'

app.use coffee_query.parse_extra_filters
app.use coffee_query.middleware

app.use (require './lib/request_logging').middleware

if conf.api.auth
  app.use require('./lib/internal').middleware
  log.info "Authentication is enabled"
else
  log.warn "Authentication is disabled via configuration"

_mount_dir = (dir,prefix=null) ->
  prefix = "/#{prefix}" if prefix and !prefix.startsWith('/')
  for x in ls "#{dir}/*.iced"
    route = '/' + _.base(x).split('.iced').shift()
    route = prefix + route if prefix
    route = route.split('//').join '/'
    app.use route, require("./#{x}")

    if !process.env.SILENCE
      log.info "Mounted route: #{route} (#{x})"

_load_crons = (dir) ->
  return if !_.exists(dir)
  for x in ls "#{dir}/*.iced"
    require("./#{x}")

    if !process.env.SILENCE
      log.info "Loaded cron: (#{_.base x})"

_mount_dir './routes'
_load_crons './cron'

_auto_expose_models = (->
  return if !conf.mongo

  bind_entity = require './lib/auto_expose'

  for model_name in mongoose.modelNames()
    model = mongoose.model(model_name)

    if opts = model.AUTO_EXPOSE
      log.info "AUTO_EXPOSE", "Exposing model :#{model_name}", opts

      bind_entity app, (bind_opts = {
        model: model
        route: (opts.route ? '/' + opt.route.toLowerCase())
        methods: (opts.methods ? [])
      })
)

_auto_expose_models()

app.get '/', (req,res,next) ->
  res.respond {
    pong: _.uuid()
  }

app.use (e,req,res,next) ->
  e = new Error(e) if _.type(e) isnt 'error'
  log.error e
  return res.respond e, 500

app.use (req,res,next) ->
  log.error "404", req.method, req.url
  res.respond (new Error 'Not found'), 404

##
if !module.parent
  app.listen conf.api.port
  log.info "Listening :#{conf.api.port}"
else
  module.exports = app

