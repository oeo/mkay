# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')({
  globals: off
})

###
eve.emit 'route_stat', 'routename', 'myreasoning'
eve.emit 'route_stat', 'routename', 'allowed'
###

###
eve.on 'Hello', ->
  log.info "Hello, world!"
###

