_ = require('wegweg')({
  globals: no
  shelljs: no
})

winston = require 'winston'

log = new winston.Logger({
  exitOnError: no
  transports: [
    new (winston.transports.Console)({
      timestamp: yes
      colorize: yes
    }),
  ]
})

module.exports = log

