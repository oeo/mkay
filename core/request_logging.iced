# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')({
  globals: off
})

cache = require 'memory-cache'

request_logging = {}

stats_template =
  count: 0
  latency: 0

stats =
  routes: {}
  total: _.clone stats_template

request_logging.middleware = (req,res,next) ->
  request_obj = {
    _id: _.uuid()
    url: req.url
    method: req.method
    route_key: [req.method,req.url].join ' '
    query: req.query ? null
    body: req.body ? null
    cdate: new Date
    metadata: req.metadata
  }
  
  log.info 'Request', req.method, req.url

  req.request_id = request_obj._id
  req.request_start = new Date

  req.breakpoint = (str) ->
    if conf.developer.show_breakpoints
      elapsed = new Date - req.request_start
      log.info "Breakpoint \"#{str}\": #{elapsed}ms"

  cache.put "request_log:#{request_obj._id}", request_obj, (30 * 1000)
  next()

eve.on 'request_log_response', (request_id) ->
  if hit = cache.get "request_log:#{request_id}"
    cache.del "request_log:#{request_id}"
    stats[hit.route_key] ?= _.clone stats_template
    ++ stats[hit.route_key].count
    ++ stats.total.count
    stats[hit.route_key].latency += (new Date - hit.cdate)
    stats.total.latency += (new Date - hit.cdate)

# pull stats
request_logging.stats = ->
  tmp = _.clone stats
  for k,v of tmp
    v.average_ms = 0
    if v.count and v.latency
      v.average_ms = (v.latency/v.count).toFixed 2
    v.route_key = k
    tmp[k] = v
  arr = _.reverse _.sortBy (_.vals(tmp)), (x) ->
    x.average_ms * -1
  arr

module.exports = request_logging

