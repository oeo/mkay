_ = require('wegweg')({
  globals: off
})

if !module.parent
  process.env.MONGOOSE_MODEL_DEVEL = module.filename
  process.env.SILENCE = 1
  require './../lib/globals'

Schema = mongoose.Schema
models = require './../lib/models'

UsersSchema = new Schema {

  active: {
    type: Boolean
    default: yes
  }

  name: {
    type: String
    trim: yes
    required: yes
  }

}, {collection:'users'}

UsersSchema.plugin models.base

UsersSchema.methods.change_name = (opt={},cb) ->
  if !opt.name then return cb new Error "`opt.name` required"
  @name = opt.name
  @save cb

##
model = mongoose.model 'Users', UsersSchema

model.AUTO_EXPOSE = {
  route: '/users'
  methods: [
    'change_name'
  ]
}

module.exports = model

