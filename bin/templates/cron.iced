_ = require('wegweg')({
  globals: off
})

if !module.parent
  process.env.SILENCE = 1
  require './../core/globals'

module.exports = routine = {
  run: ((cb) ->
    log.info "Cron running"
    return cb null, yes
  )
}

_.every '1 minute', -> routine.run -> 1

