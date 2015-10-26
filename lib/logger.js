'use babel'

module.exports = {
  info: console.log.bind(console, 'atom-node-debugger'),
  error: console.error.bind(console, 'atom-node-debugger'),
  debug: console.debug.bind(console, 'atom-node-debugger')
}
