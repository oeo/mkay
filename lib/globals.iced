_ = require('wegweg')({
  globals: on
  shelljs: on
})

root.log = require './logger'

root.ll = (x...) -> console.log x...
root.lp = (x) -> ll JSON.stringify(x,null,2)

process.env.CONFIG_FILE ?= __dirname + '/../conf'
process.env.CONFIG_FILE = _.resolve process.env.CONFIG_FILE

process.env.CONFIG_FILE_LOCAL ?= require('path').dirname(process.env.CONFIG_FILE) + '/conf.local.iced'
process.env.CONFIG_FILE_LOCAL = _.resolve process.env.CONFIG_FILE_LOCAL

if !process.env.SILENCE
  log.info "GLOBALS", "Loading config CONFIG_FILE: #{process.env.CONFIG_FILE}"

config = require process.env.CONFIG_FILE

if _.exists(process.env.CONFIG_FILE_LOCAL)
  if !process.env.SILENCE
    log.info "GLOBALS", "Merging local config CONFIG_FILE_LOCAL: #{process.env.CONFIG_FILE_LOCAL}"

  flatten = require 'flat'
  unflatten = require('flat').unflatten

  flat_extra = flatten require(process.env.CONFIG_FILE_LOCAL)
  flat_conf = flatten config

  flat_conf[k] = v for k,v of flat_extra

  config = unflatten flat_conf

root.conf = config

if conf.mongo
  if !process.env.SILENCE
    log.info "GLOBALS", "Connecting MongoDB (#{conf.mongo})"
  root.db = root.mongo = _.mongo conf.mongo
  root.col = (x) -> db.collection x

if conf.redis
  if !process.env.SILENCE
    log.info "GLOBALS", "Connecting Redis (#{conf.redis})"
  root.redis = _.redis conf.redis

if conf.memcached
  if !process.env.SILENCE
    log.info "GLOBALS", "Connecting Memcached (#{conf.memcached})"
  root.memcached = _.memcached conf.memcached

root.eve = _.eve()

if conf.mongo
  root.mongoose = require 'mongoose'
  mongoose.connect db.uri

  for x in ls "#{__dirname}/../models/*.iced"
    if process.env.MONGOOSE_MODEL_DEVEL
      if _.base(process.env.MONGOOSE_MODEL_DEVEL) is (base = _.base(x))
        if !process.env.SILENCE
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

