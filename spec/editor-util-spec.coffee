{Workspace, Editor} = require 'atom'
fs = require 'fs'
editorUtil = require '../lib/editor-util'

describe 'Editor Util', ->

  scriptStub = null
  promise = null
  editor = null

  beforeEach ->
    atom.workspace = new Workspace

  it 'should be able to jump to a script file', ->
    scriptStub =
      name: "#{__dirname}/fixtures/sample.js"
      line: 10

    waitsForPromise ->
      editorUtil.jumpToFile(scriptStub, 10).then (e) ->
        editor = e

    runs ->
      expect(editor.getText()).toBe(fs.readFileSync("#{__dirname}/fixtures/sample.js", 'utf-8'))


  it 'should be able to set the source when the file can not be open', ->
    scriptStub =
      name: "/some/file/not/exists.js"
      line: 10
      source: 'some sources'

    waitsForPromise ->
      editorUtil.jumpToFile(scriptStub, 10).then (e) ->
        editor = e

    runs ->
      expect(editor.getText()).toBe('some sources');
