# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')({
  globals: off
})

module.exports = models = {}

models.base = (schema) ->
  schema.add
    _id: String
    mtime: Number
    ctime: Number

  schema.pre 'save', (next) ->
    @mtime = (t = _.time())
    @ctime ?= t
    @_id ?= _.uuid()
    next()

