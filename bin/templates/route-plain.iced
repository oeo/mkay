_ = require('wegweg')({
  globals: off
})

app = module.exports = new (require 'express').Router

app.get '/', (req,res,next) ->
  res.respond pong:_.uuid()

