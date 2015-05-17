Promise = require 'bluebird'
fs = require 'fs'
url = require 'url'
Module = require 'module'
NonEditableEditorView = require './non-editable-editor'


PROTOCOL = 'atom-node-debugger://'

exists = (path) ->
  new Promise (resolve) ->
    fs.exists path, (isExisted) ->
      resolve(isExisted)

module.exports = (_debugger) ->
  atom.workspace.addOpener (filename, opts) ->
    parsed = url.parse(filename, true)
    if parsed.protocol is 'atom-node-debugger:'
      return new NonEditableEditorView({
        uri: filename
        id: parsed.host
        _debugger: _debugger
        query: opts
      })

  (breakpoint) ->
    {sourceLine, sourceColumn} = breakpoint
    script = breakpoint.script and breakpoint.script.name
    id = breakpoint.script?.id
    exists(script)
      .then (isExisted)->
        if isExisted
          atom.workspace.open(script, {
            initialLine: sourceLine
            initialColumn: sourceColumn
            activatePane: true
            searchAllPanes: true
          })
        else
          return if not id?
          newSourceName = "#{PROTOCOL}#{id}"
          atom.workspace.open(newSourceName, {
            initialColumn: sourceColumn
            initialLine: sourceLine
            name: script
            searchAllPanes: true
          })
