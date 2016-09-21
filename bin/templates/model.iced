_ = require('wegweg')({
  globals: off
})

if !module.parent
  process.env.MONGOOSE_MODEL_DEVEL = module.filename
  process.env.SILENCE = 1
  require './../core/globals'

Schema = mongoose.Schema
models = require './../core/models'

{{upper}}Schema = new Schema {

  active: {
    type: Boolean
    default: yes
  }

  name: {
    type: String
    trim: yes
    required: yes
  }

}, {collection:'{{lower}}'}

{{upper}}Schema.plugin models.base

##
model = mongoose.model '{{upper}}', {{upper}}Schema

model.AUTO_EXPOSE = {
  route: '/{{lower}}'
  methods: []
}

module.exports = model

