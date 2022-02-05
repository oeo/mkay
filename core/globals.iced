config = (dotenv = require('dotenv').config({
  path: _dotenv_file = (process.env.ENVFILE or (__dirname + '/../.env'))
})).parsed

for k,v of config
  config[lk] = v if !config[lk = k.toLowerCase()]

_ = require('wegweg')({
  globals: on
  shelljs: on
})

if !root
  if global? then root = global

root.conf = root.config = config

root.log = require './logger'

log.info "ENVFILE", require('path').resolve _dotenv_file

if conf.mongo
  if !env.SILENCE
    log.info "GLOBALS", "Mongo (#{conf.mongo})"
  root.db = root.mongo = _.mongo conf.mongo
  root.col = (x) -> db.collection x

if conf.redis
  if !env.SILENCE
    log.info "GLOBALS", "Redis (#{conf.redis})"
  root.redis = _.redis conf.redis

if conf.memcached
  if !process.env.SILENCE
    log.info "GLOBALS", "Memcached (#{conf.memcached})"
  root.memcached = _.memcached conf.memcached

root.eve = _.eve()

if conf.mongo
  root.mongoose = require 'mongoose'

  conn_str = (do =>
    obj = _.parse_uri(uri = conf.mongo)
    if uri.match '@'
      up = uri.split('@')[0] + '@'
    else
      up = ''
    database = uri.split('/').pop()

    return "mongodb://#{up}#{obj.hostname}:#{obj.port or 27017}#{'/' + database or ''}"
  )

  mongoose.connect conn_str, {
    useNewUrlParser: yes
    useUnifiedTopology: yes
  }

  for x in ls "#{__dirname}/../models/*.iced"
    if env.MONGOOSE_MODEL_DEVEL
      if _.base(env.MONGOOSE_MODEL_DEVEL) is (base = _.base(x))
        if !env.SILENCE
          log.warn "GLOBALS", "Skipping model #{base} (env.MONGOOSE_MODEL_DEVEL)"
        continue
    require x

  if mongoose.modelNames()
    for x in mongoose.modelNames()
      if x.endsWith('s')
        y = x.substr(0,(x.length - 1))
      else
        y = x + 's'

      model = db[x] = db[y] = mongoose.model(x)

      if !process.env.SILENCE
        log.info "GLOBALS", "Registered model: #{x}"

root.pjson = root.package_json =
  JSON.parse _.reads __dirname + '/../package.json'

process.on 'uncaughtException', (e) ->
  log.error e

  lines = e.stack?.toString().split('\n').slice(0,3)

  err = {file:no,line:no}

  for x in lines
    try
      if x.trim().substr(0,3) is 'at ' and !err.file
        parts = x.split('at ')[1]
        y = x.trim().substr(3).trim()
        y = y.split ':'
        y.pop()
        file = y[0]
        line = y[1]
        if _.exists(file)
          err.file = file
          err.line = line
    console.log x

  if err.file
    console.log '\n'
    await exec "sed -n #{err.line}p #{err.file}", {silent:yes}, defer code,response
    response = response.trim()
    console.log ('  ✘ ' + _.base(err.file) + ':' + err.line).red
    console.log ('     ' + response)
    console.log '\n'

  err_obj = {
    component: package_json.name
    message: lines.join '\n'
    ctime: _.time()
  }

  console.log JSON.stringify(err_obj,null,2)

