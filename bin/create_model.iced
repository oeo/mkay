_ = require('wegweg')({
  globals: off
})

macros = require __dirname + '/../core/macros'

generator = {}

generator.usage = (->
  console.log """
    Usage: ./ --name <model_name>
  """
  process.exit 0
)

generator.run = (->
  if _.arg('help') then @usage()
  if !(name = _.arg('name')) then @usage()

  opt = {
    name: name
  }

  await @generate opt, defer e,r
  if e then throw e

  console.log r
  process.exit 0
)

generator.generate = ((opt={},cb) ->
  required = [
    'name'
  ]

  for x in required
    if !opt[x] then return cb new Error "`opt.#{x}` required"

  if !opt.name.endsWith('s')
    opt.name = opt.name + 's'

  data = {
    name: opt.name
    lower: opt.name.toLowerCase()
    upper: _.ucfirst opt.name.toLowerCase()
  }

  bulk = _.reads __dirname + '/templates/model.iced'
  bulk = macros(bulk,data,no)

  cb null, bulk
)

if process.env.RUN_GENERATOR
  generator.run()
else
  module.exports = generator

