hg = require 'mercury'
Promise = require 'bluebird'
{h} = hg
fs = require 'fs'
ToggleTree = require './ToggleTree'

PROTOCOL = 'atom-node-debugger://'

removeBreakListener = null

exists = (path) ->
  new Promise (resolve) ->
    fs.exists path, (isExisted) ->
      resolve(isExisted)

exports.create = (_debugger) ->

  CallStackPane = () ->
    state = hg.state({
      rootToggle: ToggleTree.state('Call Stack')
      frames: hg.array([])
    })

    removeBreakListener = _debugger.onBreak () ->
      _debugger.fullTrace().then (traces) ->
        while(state.frames().length)
          state.frames.pop()

        traces.frames.forEach (frame, idx) ->
          frame = Frame(frame)
          state.frames.push(frame)

    return state

  directValueView = (item) ->
    h('li.list-item', {}, [item.vname + ": " + item.value.value])

  undefinedValueView = (value) ->
    h('li.list-item', {}, [String(value.vname) + ": undefined"])

  ObjectValue = (value) ->
    state = hg.state({
      isOpen: hg.value(false)
      vname: hg.value(value.name)
      type: hg.value(value.value.type)
      loading: hg.value(false)
      loaded: hg.value(false)
      className: hg.value(value.value.className)
      ref: hg.value(value.value.ref)
      properties: hg.array([])
      channels: {
        toggle: ObjectValue.toggleOnOff
      }
    })

    return state

  ObjectValue.toggleOnOff = (state) ->
    isOpen = state.isOpen()
    loading = state.loading()
    loaded = state.loaded()
    state.isOpen.set(!isOpen)

    return if loading
    return if loaded

    state.loading.set(true)
    _debugger
    .lookup(state.ref())
    .then (detail) ->
      Promise
      .map detail.properties, (prop) -> _debugger.lookup(prop.ref)
      .then (values) ->
        values.forEach (value, idx) ->
          detail.properties[idx].value = value

        return detail
    .then (detail) ->
      state.loaded.set(true)
      state.loading.set(false)
      detail.properties.forEach (prop) ->
        state.properties.push(Value(prop))

    .catch (e) ->
      state.loaded.set(false)
      state.loading.set(false)


  ObjectValue.render = (object) ->
    if object.isOpen
      content = "#{object.vname}: #{object.className}"
    else
      content = "#{object.vname} : #{object.className} { ... }"

    h('li.list-nested-item', {
      className: if object.isOpen then '' else 'collapsed'
    }, [
      h('div.list-item', {
        'ev-click': hg.send object.channels.toggle
      }, [content])
      h('ul.list-tree.object', {}, object.properties.map(Value.render))
    ])

  Value = (value) ->
    v = value.value
    return ObjectValue(value) if v.type is 'object'

    hg.state({
      vname: hg.value(value.name)
      type: hg.value(v.type)
      value: hg.value(value.value)
    })

  Value.render = (value) ->
    type = value.type
    return directValueView(value) if type is 'string'
    return directValueView(value) if type is 'boolean'
    return directValueView(value) if type is 'number'
    return directValueView(value) if type is 'undefined'
    return directValueView(value) if type is 'null'
    return ObjectValue.render(value) if type is 'object'
    return functionValueView(value) if type is 'function'
    return h('div', {}, ['unknown'])

  functionValueView = (value) ->
    h('li.list-item', {}, [String(value.vname) + ": function() { ... }"])

  Frame = (frame) ->
    hg.state({
      script: hg.value(frame.script.name)
      scriptId: hg.value(frame.script.id)
      line: hg.value(frame.line)
      arguments: hg.array(frame.arguments.map(Value))
      argumentsOn: hg.value(false)
      locals: hg.array(frame.locals.map(Value))
      localsOn: hg.value(false)
      isOpen: hg.value(false)
      channels: {
        toggle: Frame.toggleOnOff
        argumentToggle: Frame.onOff('argumentsOn')
        localsToggle: Frame.onOff('localsOn')
      }
    })

  Frame.onOff = (type) -> (state) ->
    state[type].set(!state[type]())

  Frame.toggleOnOff = (state) ->
    isOpen = state.isOpen()
    state.isOpen.set(!isOpen)

    exists(state.script())
      .then (isExisted)->
        if isExisted
          promise = atom.workspace.open(state.script(), {
            initialLine: state.line()
            initialColumn: 0
            activatePane: true
            searchAllPanes: true
          })
        else
          return if not state.scriptId()?
          newSourceName = "#{PROTOCOL}#{state.scriptId()}"
          promise = atom.workspace.open(newSourceName, {
            initialColumn: 0
            initialLine: state.line()
            name: state.script()
            searchAllPanes: true
          })

  Frame.render = (frame) ->
    h('ul.list-tree', {}, [
      h('li.list-nested-item', {
        className: if frame.isOpen then '' else 'collapsed'
      }, [
        h('div.list-item', {
          'ev-click': hg.send frame.channels.toggle
        }, [
          "#{frame.script}:#{frame.line + 1}"
        ])
        h('ul.list-tree', {}, [
          h('li.list-nested-item', {
            className: if frame.argumentsOn then '' else 'collapsed'
          }, [
              h('div.list-item', {
                'ev-click': hg.send frame.channels.argumentToggle
              }, [
                'arguments'
              ])
              h('ul.list-tree.arguments', {}, frame.arguments.map(Value.render))
          ])
        ])
        h('ul.list-tree', {}, [
          h('li.list-nested-item', {
            className: if frame.localsOn then '' else 'collapsed'
          }, [
              h('div.list-item', {
                'ev-click': hg.send frame.channels.localsToggle  
              }, [
                'variables'
              ])
              h('ul.list-tree.locals', {}, frame.locals.map(Value.render))
          ])
        ])
      ])
    ])

  CallStackPane.render = (state) ->
    frames = state.frames

    ToggleTree.render(state.rootToggle, frames.map(Frame.render))

  return CallStackPane

exports.cleanup = () ->
  removeBreakListener() if removeBreakListener?
