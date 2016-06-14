meta = {}

meta.middleware = (req,res,next) ->
  req.metadata = {}
  req.metadata.path = req.path
  req.metadata.body = req.body
  req.metadata.query = req.query
  req.metadata.start = new Date

  next()

module.exports = meta

