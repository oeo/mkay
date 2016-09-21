_ = require('wegweg')({
  globals: off
})

pagination = require './../core/pagination'

app = module.exports = new (require 'express').Router

app.get '/', (req,res,next) ->
  data = {}

  await
    db.{{upper}}
      .count req.coffee_filter ? {}
      .exec defer e,data.total
  return next e if e

  data.pages = pagination {
    total: data.total
    cur_page: (parseInt req.query.page ? 0)
    per_page: (parseInt req.query.per_page ? 50)
    arrow_mode: yes
  }

  await
    db.{{upper}}
      .find req.coffee_filter ? {}
      .sort req.coffee_filter_sort ? {ctime:-1}
      .skip data.pages.offset
      .limit (parseInt req.query.per_page ? 50)
      .lean()
      .exec defer e,data.items
  return next e if e

  res.respond data

app.post '/', (req,res,next) ->
  await db.{{upper}}.create req.body, defer e,r
  if e then return next e
  res.respond r

app.post '/:_id', (req,res,next) ->
  await db.{{upper}}
      .findOne _id:req.params._id
      .exec defer e,r
  if e then return next e
  r[k] = v for k,v of req.body
  await r.save defer e,r
  if e then return next e
  res.respond r

app.get '/:_id', (req,res,next) ->
  await db.{{upper}}
      .findOne _id:req.params._id
      .exec defer e,r
  if e then return next e
  res.respond r

app.delete '/:_id', (req,res,next) ->
  await db.{{upper}}
    .findOne _id:req.params._id
    .remove defer e,r
  if e then return next e
  res.respond yes

##
app.AUTO_EXPOSE = on

