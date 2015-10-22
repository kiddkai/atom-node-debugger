hg = require 'mercury'
{h} = hg
Promise = require 'bluebird'

log = (msg) -> console.log(msg)

TreeView = (title, loadChildren, { handlers, data, isRoot } = {}) ->
  log "TreeView constructor. title=#{title}, isRoot=#{isRoot}"
  return hg.state({
      render: { func: TreeView.defaultRender }
      isRoot: hg.value(isRoot)
      title: hg.value(title)
      items: hg.array([])
      isOpen: hg.value(false)
      loading: hg.value(false)
      loaded: hg.value(false)
      data: data
      channels: {
        click:
          (state) ->
            TreeView.toggle(state, loadChildren)
            handlers?.click?(state.data)
        reset: (state) -> TreeView.reset(state, loadChildren)
      }
    })

TreeView.toggle = (state, loadChildren) ->
  log "TreeView.toggle #{state.isOpen()} item count=#{state.items().length} loaded=#{state.loaded()}, loading=#{state.loading()}"
  state.isOpen.set(!state.isOpen())
  return if state.loading() or state.loaded()
  TreeView.populate(state, loadChildren)

TreeView.reset = (state) ->
  log "TreeView.reset"
  return unless state.loaded()
  while(state.items().length)
    state.items.pop()

  state.isOpen.set(false)
  state.loaded.set(false)
  state.loading.set(false)
  log "TreeView.reset: done"

TreeView.populate = (state, loadChildren) ->
  log "TreeView.populate"
  state.loading.set(true)
  loadChildren()
  .then (children) ->
    log "TreeView.populate: children loaded. count=#{children.length})"
    children.forEach (child) ->
      state.items.push(child)
  .then () ->
    log "TreeView.populate: all done"
    state.loaded.set(true)
    state.loading.set(false)
  .catch (e) ->
    log("TreeView.populate:error!!!" + JSON.stringify(e))
    state.loaded.set(false)
    state.loading.set(false)

TreeView.render = (state) ->
  return state.render.func(state)

TreeView.defaultRender = (state) ->
  log "TreeView.render"
  title = state.title?(state) ? state.title
  result = h('li.list-nested-item', {
        className: if state.isOpen then '' else 'collapsed'
      }, [
        h('div.header.list-item' + (if state.isRoot then '.heading' else ''), { 'ev-click': hg.send state.channels.click }, [title]),
        h('ul.entries.list-tree', {}, state.items.map(TreeView.render))
      ])

  result = h('div.debugger-vertical-pane.inset-panel', {}, [
      h('ul.list-tree.has-collapsable-children', {}, [result])
    ]) if state.isRoot
  return result

TreeViewItem = (value, { handlers, data } = {}) -> hg.state({
    render: { func: TreeViewItem.render }
    value: hg.value(value)
    data: data
    channels: {
      click:
        (state) -> handlers?.click?(state.data)
    }
  })

TreeViewItem.render = (state) ->
  h('li.list-item.entry', { 'ev-click': hg.send state.channels.click }, [state.value])

exports.TreeView = TreeView
exports.TreeViewItem = TreeViewItem
