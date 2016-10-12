App = require './Components/App'

$rootBottom = null
$rootRight = null
$panelBottom = null
$panelRight = null
isInited = false
$panel2 = null
appBottom = null
appRight = null

exports.show = (_debugger) ->
  if not isInited
    $rootBottom = document.createElement('div')
    $rootRight = document.createElement('div')
    $rootRight.style = "display:flex" # had to set flex here to get the splitter to fill the vertical space
    appBottom = App.startBottom($rootBottom, _debugger)
    appRight = App.startRight($rootRight, _debugger)

  $panelBottom = atom.workspace.addBottomPanel(item: $rootBottom)
  $panelRight = atom.workspace.addRightPanel(item: $rootRight)
  isInited = true

exports.hide = ->
  $panelBottom.destroy() if $panelBottom
  $panelRight.destroy() if $panelRight
  atom.workspace.getActivePane().activate()

exports.destroy = ->
  exports.hide()
  App.stop()
  isInited = false
  $rootBottom.remove() if $rootBottom?
  $rootRight.remove() if $rootRight?
  $rootBottom = null
  $rootRight = null

exports.toggle = ->
  return unless isInited
  unless appBottom.collapsed() and appRight.collapsed()
    appBottom.collapsed.set(true)
    appRight.collapsed.set(true)
  else
    appBottom.collapsed.set(false)
    appRight.collapsed.set(false)
