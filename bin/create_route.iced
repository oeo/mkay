_ = require('wegweg')({
  globals: off
})

macros = require __dirname + '/../core/macros'

generator = {}

generator.usage = (->
  console.log """
    Usage: ./ [--model <model_name>] or [--plain]
  """
  process.exit 0
)

generator.run = (->
  if _.arg('help') then @usage()
  if !_.arg('model') and !_.arg('plain') then @usage()

  opt = {
    model: _.arg('model') ? no
  }

  await @generate opt, defer e,r
  if e then throw e

  console.log r
  process.exit 0
)

generator.generate = ((opt={},cb) ->
  if opt.model
    if !opt.model.endsWith('s')
      opt.model = opt.model + 's'

    if !_.exists(file = __dirname + '/../models/' + opt.model.toLowerCase() + '.iced')
      return cb new Error "Model file `#{file}` not found"

  if opt.model
    data = {
      name: opt.model
      lower: opt.model.toLowerCase()
      upper: _.ucfirst opt.model.toLowerCase()
    }

    bulk = _.reads __dirname + '/templates/route.iced'
    bulk = macros(bulk,data,no)
  else
    data = {}

    bulk = _.reads __dirname + '/templates/route-plain.iced'
    bulk = macros(bulk,data,no)

  cb null, bulk
)

if process.env.RUN_GENERATOR
  generator.run()
else
  module.exports = generator

