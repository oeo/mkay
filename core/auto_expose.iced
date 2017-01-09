_ = require('wegweg')({
  globals: off
})

express = require 'express'
mongoose = require 'mongoose'

pagination = require './pagination'

module.exports = bind_entity = ((app,opt={}) ->

  for x in ['model','route']
    if !opt?[x]
      throw new Error "`opt.#{x}` required"

  model = opt.model
  router = express.Router()

  # bind instance methods
  if opt?.methods?.length and _.keys(model.schema.methods).length
    for x in _.keys(model.schema.methods)
      continue if x !in opt.methods

      do (x) =>
        if !process.env.SILENCE
          log.info "AUTO_EXPOSE", "Binding model instance method `#{model.modelName}/#{x}()` to `POST #{opt.route}/:_id/#{x}`"

        router.post "/:_id/#{x}", (req,res,next) ->
          await model
            .findOne({_id:req.params._id})
            .exec defer e,item

          if e then return next e
          if !item then return next new Error 'Document not found'

          await item[x] req.body, defer e,r
          if e then return next e

          return res.respond r

  # bind static methods
  if opt?.statics?.length and _.keys(model.schema.statics).length
    for x in _.keys(model.schema.statics)
      continue if x !in opt.statics

      do (x) =>
        if !process.env.SILENCE
          log.info "AUTO_EXPOSE", "Binding model static method `#{model.modelName}/#{x}()` to `POST #{opt.route}/#{x}`"

        router.post "/#{x}", (req,res,next) ->
          await model[x] req.body, defer e,r
          if e then return next e
          return res.respond r

  if !process.env.SILENCE
    log.info "AUTO_EXPOSE", "Binding crud routes for `#{model.modelName}` to `#{opt.route}`"

  # bind create
  router.post '/', (req,res,next) ->
    await model.create req.body, defer e,r
    if e then return next e
    return res.respond r

  # bind show one
  router.get '/:_id', (req,res,next) ->
    await model
      .findOne({_id:req.params._id})
      .lean()
      .exec defer e,item

    if e then return next e
    if !item then return next new Error 'Document not found'
    return res.respond item

  # bind update
  router.post '/:_id', (req,res,next) ->
    await model
      .findOne({_id:req.params._id})
      .exec defer e,item

    if e then return next e
    if !item then return next new Error 'Document not found'

    for k,v of req.body
      item[k] = v

    await item.save defer e,r
    if e then return cb e

    return res.respond r

  # bind delete
  router.delete '/:_id', (req,res,next) ->
    await model
      .findOne({_id:req.params._id})
      .exec defer e,item

    if e then return next e
    if !item then return next new Error 'Document not found'

    await item.remove defer e,r
    if e then return cb e

    return res.respond r

  # bind list
  router.get '/', (req,res,next) ->
    data = {}

    await
      model
        .count req.coffee_filter ? {}
        .exec defer e,data.total
    return next e if e

    data.pages = pagination {
      total: data.total
      cur_page: (parseInt req.query.page ? 0)
      per_page: (parseInt req.query.per_page ? req.query.limit ? 100)
      arrow_mode: yes
    }

    await
      model
        .find req.coffee_filter ? {}
        .sort req.coffee_filter_sort ? {ctime:-1}
        .skip data.pages.offset
        .limit (parseInt req.query.per_page ? req.query.limit ? 100)
        .lean()
        .exec defer e,data.items
    return next e if e

    return res.respond data

  app.use opt.route, router
  return app
)

###
bind_entity app, {
  model: Customer
  route: '/customers'
  methods: ['change_name']
}

# http://localhost:5050/customers/61g7meeyfawt/change_name?method=post&new_name=chris
# {"_id":"61g7meeyfawt","ctime":1463858225,"mtime":1463858632,"comment":"Hello","name":"chris","__v":0,"last_name_change":1463858632}
###

