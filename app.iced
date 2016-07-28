_ = require('wegweg')({
  globals: on
  shelljs: on
})

cluster = require 'cluster'

if cluster.isWorker
  process.env.SILENCE = 1

require './lib/globals'
require './lib/listeners'

if !conf.cluster or cluster.isMaster
  require './lib/startup'

  _load_crons = (dir) ->
    return if !_.exists(dir)
    for x in ls "#{dir}/*.iced"
      require("./#{x}")

      if !process.env.SILENCE
        log.info "APP", "Loaded cron: (#{_.base x})"

  _load_crons './cron'

  if conf.cluster
    if !process.env.SILENCE
      log.info "APP", 'Cluster mode enabled via configuration'

    num = require('os').cpus().length

    for x in [1..num]
      if !process.env.SILENCE
        log.info "APP", 'MASTER', 'Spawning child'
      cluster.fork()

    cluster.on 'exit', ->
      log.warn "APP", 'MASTER', 'Respawning child'
      cluster.fork()

if !conf.cluster or cluster.isWorker

  app = _.app({
    static: off
    body_parser: on
  })

  app.use ((req,res,next) ->
    needles = [
      ':ffff:'
      '127.0.0.1'
      '::'
    ]

    for x in needles
      if req.real_ip.includes(x)
        req.real_ip = '127.0.0.1'
        req.real_ip = ip if ip = conf.developer.debug_ip
        break

    return next()
  )

  # allow method override
  if conf.allow_http_method_override
    if !process.env.SILENCE
      log.warn "APP", 'Allowing HTTP method override using `req.query` (`?method=post`)'

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

      return next()
    )

  app.use (require './lib/api_response').middleware

  if conf.developer.show_error_stack
    if !process.env.SILENCE
      log.warn 'APP', 'DEVELOPER', "Error stack is exposed in browser via configuration"

  app.use (require './lib/metadata').middleware

  coffee_query = require './lib/coffee_query'

  app.use coffee_query.parse_extra_filters
  app.use coffee_query.middleware

  app.use (require './lib/request_logging').middleware

  if conf.api.auth
    app.use require('./lib/internal').middleware
    if !process.env.SILENCE
      log.info "APP", "Authentication is enabled"
  else
    if !process.env.SILENCE
      log.warn "APP", "Authentication is disabled via configuration"

  if conf.cookie_session.enabled
    app.use require('cookie-session')(session_conf = {
      name: (conf.cookie_session.name ? 's')
      secret: conf.cookie_session.secret_key
    })

    app.use (req,res,next) ->
      res.locals.session = req.session
      return next()

    if !process.env.SILENCE
      log.info 'APP', "Cookie session enabled: #{session_conf.name}/#{session_conf.secret}"

  if _.exists(dir = __dirname + '/views')
    exphbs  = require('express-handlebars')

    app.engine('.hbs',exphbs({
      layout: no
      extname: '.hbs'
      partialsDir: dir
      helpers: require('./lib/hbs_helpers')
    }))

    app.set('view engine','hbs')

    if !process.env.SILENCE
      log.info "APP", "Adding Handlebars render engine: views/*.hbs"

  if _.exists(dir = __dirname + '/static')
    app.use('/static',require('express').static('static'))

    if !process.env.SILENCE
      log.info "APP", "Serving static assets: static/*: /static"

  _mount_dir = (dir,prefix=null) ->
    prefix = "/#{prefix}" if prefix and !prefix.startsWith('/')
    for x in ls "#{dir}/*.iced"
      route = '/' + _.base(x).split('.iced').shift()
      route = prefix + route if prefix
      route = route.split('//').join '/'

      route = '/' if _.base(x).startsWith('_')

      app.use (route), require("./#{x}")

      if !process.env.SILENCE
        log.info "APP", "Mounted route: #{route} (#{x})"

  _load_crons = (dir) ->
    return if !_.exists(dir)
    for x in ls "#{dir}/*.iced"
      require("./#{x}")

      if !process.env.SILENCE
        log.info "APP", "Loaded cron: (#{_.base x})"

  _mount_dir './routes'

  _auto_expose_models = (->
    return if !conf.mongo

    bind_entity = require './lib/auto_expose'

    for model_name in mongoose.modelNames()
      model = mongoose.model(model_name)

      if opts = model.AUTO_EXPOSE

        if !process.env.SILENCE
          log.info "AUTO_EXPOSE", "Exposing model :#{model_name}", opts

        bind_entity app, (bind_opts = {
          model: model
          route: (opts.route ? '/' + opt.route.toLowerCase())
          methods: (opts.methods ? [])
          statics: (opts.statics ? [])
        })
  )

  if conf.allow_model_exposure
    _auto_expose_models()
  else
    if !process.env.SILENCE
      log.warn 'APP', "AUTO_EXPOSE", "Model exposure disabled via configuration"

  app.use (req,res,next) ->
    res.locals.conf = conf
    return next()

  # underscore routes
  if conf.allow_underscore_routes
    app.get '/_/ping', (req,res,next) ->
      res.respond {pong:_.uuid()}

    app.get '/_/stats', (req,res,next) ->
      res.respond (require './lib/request_logging').stats()

    if !process.env.SILENCE
      log.warn 'APP', 'Underscore routes enabled'

  app.use (e,req,res,next) ->
    e = new Error(e) if _.type(e) isnt 'error'
    log.error e
    return res.respond e, 500

  app.use (req,res,next) ->
    log.error "404", req.method, req.url
    return res.respond (new Error 'Not found'), 404

  if cluster.isWorker
    if !process.env.SILENCE
      log.info "APP", "WORKER", "Listening :#{conf.api.port}"
  else
    if !process.env.SILENCE
      log.info "APP", "Listening :#{conf.api.port}"

  app.listen conf.api.port

