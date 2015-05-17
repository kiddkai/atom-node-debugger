bunyan = require 'bunyan'
path = require 'path'
fs = require 'fs'

logStream = fs.createWriteStream(path.join(__dirname, '..', '/debugger.log'))

module.exports = bunyan.createLogger({
  name: 'debugger',
  stream: logStream,
  level: 'info'
})
