_ = require('wegweg')({
  globals: off
})

if !module.parent
  process.env.MONGOOSE_MODEL_DEVEL = module.filename
  process.env.SILENCE = 1
  require './../core/globals'

Schema = mongoose.Schema
models = require './../core/models'

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

UsersSchema.statics.find_names = (opt={},cb) ->
  return cb null, ['John','James','Jose']

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
  statics: [
    'find_names'
  ]
}

module.exports = model

