hg = require 'mercury'
h = hg.h

stepButton = require './StepButton'
dragHandler = require './drag-handler'
logger = require '../logger'


exports.start = (root, _debugger) ->
  StepButton = stepButton.StepButton(_debugger)

  stepContinue = StepButton('continue', 'continue')
  stepIn = StepButton('step in', 'in')
  stepOut = StepButton('step out', 'out')
  stepNext = StepButton('step next', 'next')

  resizePanel = (state, data) ->
    state.height.set(data.height)

  App = ->
    define = {
      height: hg.value 100
      channels: {
        resizePanel: resizePanel
      }
      steps: {
        stepIn: stepIn
        stepOut: stepOut
        stepNext: stepNext
        stepContinue: stepContinue
      }
    }

    logger.info 'app init', define

    hg.state(define)

  App.render = (state) ->
    logger.info 'app state', state

    h 'div', {
      style:
        height: "#{state.height}px"
    }, [
      h('div.resizer', {
        style:
          height: '10px'
          cursor: 'ns-resize'
        'ev-mousedown': dragHandler state.channels.resizePanel, {}
      })
      StepButton.render(state.steps.stepContinue)
      StepButton.render(state.steps.stepNext)
      StepButton.render(state.steps.stepIn)
      StepButton.render(state.steps.stepOut)
    ]

  hg.app(root, App(), App.render)

exports.stop = ->
