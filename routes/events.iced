_ = require('wegweg')({
  globals: off
})

app = module.exports = new (require 'express').Router

app.get '/public-method', (req,res,next) ->
  res.respond {custom_data:_.uuid()}

##
app.AUTO_EXPOSE = {
  route: '/events'
  public: yes
}

