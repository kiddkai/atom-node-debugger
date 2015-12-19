Promise = require 'bluebird'
{TreeView, TreeViewItem, TreeViewUtils} = require './TreeView'
hg = require 'mercury'
fs = require 'fs'
{EventEmitter} = require 'events'
{h} = hg

#######################################

removeBreakListener = null

log = (msg) -> #console.log(msg)

openScript = (scriptId, script, line) ->

  PROTOCOL = 'atom-node-debugger://'
  scriptExists = new Promise (resolve) ->
    fs.exists script, (result) ->
      resolve(result)

  scriptExists
    .then (exists) ->
      if exists
        atom.workspace.open(script, {
          initialLine: line
          initialColumn: 0
          activatePane: true
          searchAllPanes: true
        })
      else
        return if not state.scriptId()?
        atom.workspace.open("#{PROTOCOL}#{scriptId}", {
          initialColumn: 0
          initialLine: line
          name: script
          searchAllPanes: true
        })

exports.create = (_debugger) ->

  eventEmitter = new EventEmitter()

  builder =
    # helper: move to debugger?
    loadProperties: (ref) ->
      log "builder.loadProperties #{ref}"
      _debugger
      .lookup(ref)
      .then (instance) ->
        log "builder.loadProperties: instance loaded"
        Promise
        .map instance.properties, (prop) ->
          _debugger.lookup(prop.ref)
        .then (values) ->
          log "builder.loadProperties: property values loaded"
          values.forEach (value, idx) ->
            instance.properties[idx].value = value
          return instance.properties

    # helper: move to debugger?
    loadFrames: () ->
      log "builder.loadFrames"
      _debugger.fullTrace()
      .then (traces) ->
        log "builder.loadFrames: frames loaded #{traces.frames.length}"
        return traces.frames

    property: (property) ->
      log "builder.property"
      builder.value({
        name: property.name
        value: {
          ref: property.ref
          type: property.value.type
          className: property.value.className
          value: property.value.value
        }
      })

    value: (value) ->
      log "builder.value"
      name = value.name
      type = value.value.type
      className = value.value.className
      switch(type)
        when 'string', 'boolean', 'number', 'undefined', 'null'
          value = value.value.value
          TreeViewItem("#{name} : #{value}")
        when 'function'
          TreeViewItem("#{name} : function() { ... }")
        when 'object'
          decorate = (title) -> (state) -> if state.isOpen then title else "#{title} { ... }"
          ref = value.value.ref
          TreeView(decorate("#{name} : #{className}"), (() => builder.loadProperties(ref).map(builder.property)))

    frame: (frame) ->
      log "builder.frame #{frame.script.name}, #{frame.script.line}"
      return TreeView(
          TreeViewUtils.createFileRefHeader frame.script.name, frame.line + 1
          (() =>
            Promise.resolve([
              TreeView("arguments", (() => Promise.resolve(frame.arguments).map(builder.value)))
              TreeView("variables", (() => Promise.resolve(frame.locals).map(builder.value)))
            ])
          ),
          handlers: {
              click: () ->
                openScript(frame.script.id, frame.script.name, frame.line)
                eventEmitter.emit('frame-selected', frame)
          }
        )

    root: () ->
      log "builder.root"
      TreeView("Call stack", (() -> builder.loadFrames().map(builder.frame)), isRoot: true)

  CallStackPane = () ->
    state = builder.root()
    removeBreakListener = _debugger.onBreak () ->
      log "Debugger.break"
      TreeView.reset(state)
      eventEmitter.emit('frame-selected', null)
    return state

  CallStackPane.render = (state) ->
    TreeView.render(state)

  builder2 =
    selectedFrame: null

    loadLocals: () ->
      framePromise = if builder2.selectedFrame then Promise.resolve(builder2.selectedFrame)
      else builder.loadFrames().then (frames) -> return frames[0]

      framePromise
      .then (frame) ->
        return frame.arguments.concat(frame.locals)

    root: () ->
      TreeView("Locals", (() -> builder2.loadLocals().map(builder.value)), isRoot:true)

  LocalsPane = () ->
    state = builder2.root()
    refresh = () -> TreeView.populate(state)
    eventEmitter.on 'frame-selected', (frame) ->
      log "Frame selected"
      builder2.selectedFrame = frame
      refresh()
    return state

  LocalsPane.render = (state) ->
    TreeView.render(state)

  return {
    CallStackPane: CallStackPane
    LocalsPane: LocalsPane
  }

exports.cleanup = () ->
  removeBreakListener() if removeBreakListener?
