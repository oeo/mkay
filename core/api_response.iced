# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')({
  globals: off
})

module.exports = api_response = {}

api_response.middleware = (req,res,next) ->
  res.respond = (data,status=null) ->
    eve.emit 'request_log_response', req.request_id

    req.metadata.elapsed = new Date - req.metadata.start
    delete req.metadata.start

    if _.type(data) is 'error'
      obj =
        ok: no
        response: data.toString()
        error: data.toString().substr("Error: ".length)
        component: pjson.name
        _meta: req.metadata

      if conf.developer.show_error_stack and data.stack
        obj.error_stack = data.stack

    else
      obj =
        ok: yes
        response: data
        _meta: req.metadata

    res.status = status if status
    formats = ['json','jsonp','xml']

    format_input = req.query.format ? req.body.format

    if format_input and format_input in formats
      format = format_input
    else
      format = 'json'

    if format is 'json'
      if req.query.pretty
        res.set 'content-type', 'text/json'
        return res.end JSON.stringify obj, null, 2
      else
        return res.json obj

    if format is 'jsonp'
      if (cbfn = req.query.cb) and !req.query.callback
        req.query.callback = cbfn
      return res.jsonp obj

    if format is 'xml'
      res.set 'content-type', 'text/xml'
      return res.end require('json2xml')({root:obj},{header:on})

  next()

