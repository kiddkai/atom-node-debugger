Promise = require 'bluebird'
{TreeView, TreeViewItem, TreeViewUtils} = require './TreeView'
hg = require 'mercury'
fs = require 'fs'
{h} = hg
FocusHook = require('./focus-hook');

#######################################

listeners = []

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
        return if not scriptId?
        atom.workspace.open("#{PROTOCOL}#{scriptId}", {
          initialColumn: 0
          initialLine: line
          name: script
          searchAllPanes: true
        })

exports.create = (_debugger) ->

  builder =
    loadProperties: (ref) ->
      log "builder.loadProperties #{ref}"
      _debugger
      .lookup(ref)
      .then (instance) ->
        log "builder.loadProperties: instance loaded"
        if instance.className is "Date"
          return [{
              name: "value"
              value:
                type: "string"
                className: "string"
                value: instance.value
            }]
        else
          Promise
          .map instance.properties, (prop) ->
            _debugger.lookup(prop.ref)
          .then (values) ->
            log "builder.loadProperties: property values loaded"
            values.forEach (value, idx) ->
              instance.properties[idx].value = value
            return instance.properties

    loadArrayLength: (ref) ->
      _debugger
      .lookup(ref)
      .then (instance) ->
        _debugger.lookup(instance.properties[0].ref)
      .then (result) ->
        result.value

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

    value: (value, handlers) ->
      log "builder.value"
      name = value.name
      type = value.value.type
      className = value.value.className
      switch(type)
        when 'string', 'boolean', 'number', 'undefined', 'null'
          value = value.value.value
          TreeViewItem("#{name} : #{value}", handlers: handlers)
        when 'function'
          TreeViewItem("#{name} : function() { ... }", handlers: handlers)
        when 'object'
          ref = value.value.ref || value.value.handle
          isArray = className is "Array"
          (if isArray then builder.loadArrayLength(ref) else Promise.resolve(0)).then (len) ->
            decorate =
              (title) ->
                (state) ->
                  if state.isOpen
                    title
                  else
                    if isArray
                      "#{title} [ #{len} ]"
                    else
                      "#{title} { ... }"

            TreeView(decorate("#{name} : #{className}"), (() => builder.loadProperties(ref).map(builder.property)), handlers: handlers)

    frame: (frame, index) ->
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
                _debugger.setSelectedFrame frame, index
          }
        )

    root: () ->
      log "builder.root"
      TreeView("Call stack", (() -> builder.loadFrames().map(builder.frame)), isRoot: true)

  CallStackPane = () ->
    state = builder.root()
    listeners.push _debugger.onBreak () ->
      log "Debugger.break"
      TreeView.reset(state)
    listeners.push _debugger.onSelectedFrame ({index}) ->
      state.items.forEach((item,i) -> if i isnt index then item.isOpen.set(false));

    return state

  CallStackPane.render = (state) ->
    TreeView.render(state)

  builder2 =
    selectedFrame: null

    loadThis: () ->
      _debugger.eval("this")
      .then (result) ->
        return [{
          name: "___this___"
          value: result
        }]
      .catch ->
        return []

    loadLocals: () ->
      framePromise = if builder2.selectedFrame then Promise.resolve(builder2.selectedFrame)
      else builder.loadFrames().then (frames) -> return frames[0]
      thisPromise = builder2.loadThis()

      Promise.all [framePromise, thisPromise]
      .then (result) ->
        frame = result[0]
        _this = result[1]
        return _this.concat(frame.arguments.concat(frame.locals))

    root: () ->
      sortLocals = (locals) ->
        locals.sort((a,b) -> a.name.localeCompare(b.name));
        return locals;
      TreeView("Locals", (() -> builder2.loadLocals().then(sortLocals).map(builder.value)), isRoot:true)

  LocalsPane = () ->
    state = builder2.root()
    refresh = () -> TreeView.populate(state)
    listeners.push _debugger.onSelectedFrame ({frame}) ->
      builder2.selectedFrame = frame
      refresh()
    return state

  LocalsPane.render = (state) ->
    TreeView.render(state)

  TreeViewWatchItem = (expression) -> hg.state({
      expression: hg.value(expression)
      value: hg.array([]) # keeping the sub component in an array is a workaround. hg.value causes problem of not re-rendering when expanding expressions
      editMode: hg.value(false)
      deleted: hg.value(false)
      channels: {
        startEdit:
          (state) ->
            log "TreeViewWatchItem.dblclick"
            state.editMode.set(true)
        cancelEdit:
          (state) ->
            state.editMode.set(false)
        finishEdit:
          (state, data) ->
            return unless state.editMode()
            state.expression.set(data.expression)
            TreeViewWatchItem.load(state)
            state.editMode.set(false)
            state.deleted.set(true) if data.expression is ""
      }
      functors: {
        render: TreeViewWatchItem.render
      }
    })

  TreeViewWatchItem.load = (state) ->
      log "TreeViewWatchItem.load #{state.expression()}"
      if state.expression() is ""
        return new Promise (resolve) ->
          t = TreeViewItem("<expression not set - double click to edit>", handlers: { dblclick: () => state.editMode.set(true) })
          state.value.set([t])
          resolve(state)

      _debugger.eval(state.expression())
      .then (result) =>
        ref = { name: state.expression(), value: result }
        builder.value(ref, { dblclick: () => state.editMode.set(true) })
      .then (t) =>
        state.value.set([t])
        return state
      .catch (error) =>
        t = TreeViewItem("#{state.expression()} : #{error}", handlers: { dblclick: () => state.editMode.set(true) })
        state.value.set([t])
        return state

  TreeViewWatchItem.render = (state) ->
    return h('div', {}, []) if state.deleted
    ESCAPE = 27
    content =
      if state.editMode
        input = h("input.form-control.input-sm.native-key-bindings", {
            value: state.expression
            name: "expression"
            placeholder: "clear content to delete slot" if state.expression is ""
            # when we need an RPC invocation we add a
            # custom mutable operation into the tree to be
            # invoked at patch time
            'ev-focus': FocusHook() if state.editMode,
            'ev-keydown': hg.sendKey(state.channels.cancelEdit, null, {key: ESCAPE}),
            'ev-event': hg.sendSubmit(state.channels.finishEdit)
            'ev-blur': hg.sendValue(state.channels.finishEdit)
            style: {
              display: 'inline'
            }
          }, [])
        h('li.list-item.entry', { 'ev-dblclick': hg.send(state.channels.startEdit) }, [input])
      else
        state.value.map(TreeView.render)[0]
    content

  builder3 =
    root: () ->
      evalExpressions = (state) ->
        filtered = state.items.filter (x) -> not(x.deleted())
        newstate = filtered.map TreeViewWatchItem.load
        result = []
        newstate.forEach (x) -> result.push(x)
        Promise.all(result)

      title = (state) ->
        h("span", {}, [
          "Watch"
          h("input.btn.btn-xs", {
              type: "button"
              value: "+"
              style:
                'margin': '1px 1px 2px 5px'
              'ev-click':
                  hg.send state.channels.customEvent
          }, [])
        ])

      return TreeView(title, evalExpressions, isRoot:true, handlers: {
          customEvent: (state) ->
            log "TreeViewWatch custom event handler invoked"
            state.isOpen.set(true)
            TreeViewWatchItem.load(TreeViewWatchItem("")).then (i) ->
              state.items.push(i)
        })

  WatchPane = () ->
    state = builder3.root()
    refresh = () -> TreeView.populate(state)
    listeners.push _debugger.onBreak () -> refresh()
    listeners.push _debugger.onSelectedFrame () -> refresh()
    return state

  WatchPane.render = (state) ->
    TreeView.render(state)

  return {
    CallStackPane: CallStackPane
    LocalsPane: LocalsPane
    WatchPane: WatchPane
  }

exports.cleanup = () ->
  for remove in listeners
    remove()
