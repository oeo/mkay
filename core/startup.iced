# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')()

if _.exists(f = __dirname + '/../.ascii')
  log.info (_.reads f
    .split '{{info}}'
    .join [pjson.name,pjson.version].join '@'
  )

