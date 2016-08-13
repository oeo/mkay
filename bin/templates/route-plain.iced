_ = require('wegweg')({
  globals: off
})

app = module.exports = new (require 'express').Router

app.get '/ping', (req,res,next) ->
  res.respond pong:_.uuid()

##
app.AUTO_EXPOSE = on

