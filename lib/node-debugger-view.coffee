App = require './Components/App'

$rootBottom = null
$rootRight = null
$panelBottom = null
$panelRight = null
isInited = false
$panel2 = null

exports.show = (_debugger) ->
  if not isInited
    $rootBottom = document.createElement('div')
    $rootRight = document.createElement('div')
    $rootRight.style = "display:flex" # had to set flex here to get the splitter to fill the vertical space
    App.startBottom($rootBottom, _debugger)
    App.startRight($rootRight, _debugger)

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
  if isInited
    if $panelBottom.isVisible()
      $panelBottom.hide()
    else
      $panelBottom.show()
    if $panelRight.isVisible()
      $panelRight.hide()
    else
      $panelRight.show()
