_ = require('wegweg')({
  globals: off
})

app = module.exports = new (require 'express').Router

app.get '/custom_event', (req,res,next) ->
  res.respond {custom_data:_.uuid()}

