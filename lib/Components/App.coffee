hg = require 'mercury'
h = hg.h

stepButton = require './StepButton'
breakpointPanel = require './BreakPointPane'
callstackPane = require './CallStackPane'
consolePane = require './ConsolePane'
cancelButton = require './CancelButton'
dragHandler = require './drag-handler'
logger = require '../logger'

StepButton = null
BreakPointPane = null

LeftSidePane = (ConsolePane, state) ->
  h('div', {
    style: {
      display: 'flex'
      flex: 'auto'
      flexDirection: 'column'
    }
  }, [
    ConsolePane.render(state.logger)
  ])

RightSidePane = (BreakPointPane, CallStackPane, StepButton, state) ->
  h('div', {
    style: {
      display: 'flex'
      witdh: "#{state.sideWidth}px"
      flexBasis: "#{state.sideWidth}px"
      height: "#{state.height}px"
      flexDirection: 'row'
    }
  }, [
    h('div.resizer', {
      style:
        width: '5px'
        flexBasis: '5px'
        cursor: 'ew-resize'
      'ev-mousedown': dragHandler state.channels.changeWidth, {}
    })
    h('div.inset-panel', {
      style: {
        flexDirection: 'column'
        display: 'flex'
        flex: 'auto'
      }
    }, [
      h('div.debugger-panel-heading', {
      }, [
        h('div.btn-group', {}, [
          StepButton.render(state.steps.stepContinue)
          StepButton.render(state.steps.stepNext)
          StepButton.render(state.steps.stepIn)
          StepButton.render(state.steps.stepOut)
          cancelButton.render(state.cancel)
        ])
      ])
      h('div.panel-body', {
        style: {
          flex: 'auto'
          display: 'flex'
          flexDirection: 'column'
          overflow: 'auto';
        }
      }, [
        BreakPointPane.render(state.breakpoints)
        CallStackPane.render(state.callstack)
      ])
    ])
  ])


exports.start = (root, _debugger) ->
  StepButton = stepButton.StepButton(_debugger)
  BreakPointPane = breakpointPanel.create(_debugger)
  CallStackPane = callstackPane.create(_debugger)
  ConsolePane = consolePane.create(_debugger)

  changeHeight = (state, data) ->
    state.height.set(data.height)

  changeWidth = (state, data) ->
    state.sideWidth.set(data.sideWidth)

  App = ->
    stepContinue = StepButton('continue', 'continue')
    stepIn = StepButton('step in', 'in')
    stepOut = StepButton('step out', 'out')
    stepNext = StepButton('step next', 'next')

    define = {
      height: hg.value 350
      sideWidth: hg.value 400
      channels: {
        changeHeight: changeHeight
        changeWidth: changeWidth
      }
      steps: {
        stepIn: stepIn
        stepOut: stepOut
        stepNext: stepNext
        stepContinue: stepContinue
      }
      breakpoints: BreakPointPane()
      callstack: CallStackPane()
      logger: ConsolePane()
      cancel: cancelButton.create(_debugger)
    }

    logger.info 'app init', define

    hg.state(define)

  App.render = (state) ->
    logger.info 'app state', state

    h('div', {
      style: {
        display: 'flex'
        flex: 'auto'
        flexDirection: 'column'
        position: 'relative'
        height: "#{state.height}px"
      }
    }, [
      h('div.resizer', {
        style:
          height: '5px'
          cursor: 'ns-resize'
        'ev-mousedown': dragHandler state.channels.changeHeight, {}
      })
      h('div', {
        style: {
          display: 'flex'
          flex: 'auto'
          flexDirection: 'row'
        }
      }, [
        LeftSidePane(ConsolePane, state)
        RightSidePane(BreakPointPane, CallStackPane, StepButton, state)
      ])
    ])

  hg.app(root, App(), App.render)

exports.stop = ->
  BreakPointPane.cleanup() if BreakPointPane
  callstackPane.cleanup()
