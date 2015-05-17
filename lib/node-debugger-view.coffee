App = require './Components/App'

$root = null
$panel = null
isInited = false

exports.show = (_debugger) ->
  if not isInited
    $root = document.createElement('div')
    App.start($root, _debugger)

  $panel = atom.workspace.addBottomPanel(item: $root)
  isInited = true

exports.hide = ->
  return unless $panel
  $panel.destroy()
  atom.workspace.getActivePane().activate()

exports.destroy = ->
  exports.hide()
  App.stop()
  isInited = false
  $root.remove() if $root?
  $root = null
