_ = require('wegweg')({
  globals: off
})

macros = require __dirname + '/../core/macros'

generator = {}

generator.usage = (->
  console.log """
    Usage: ./
  """
  process.exit 0
)

generator.run = (->
  if _.arg('help') then @usage()

  await @generate {}, defer e,r
  if e then throw e

  console.log r
  process.exit 0
)

generator.generate = ((opt={},cb) ->
  data = opt

  bulk = _.reads __dirname + '/templates/cron.iced'
  bulk = macros(bulk,data,no)

  cb null, bulk
)

if process.env.RUN_GENERATOR
  generator.run()
else
  module.exports = generator

