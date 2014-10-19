FunctionalView = require '../lib/functional-view'

describe 'Functional View', ->

  functionalView = null

  beforeEach ->
    functionalView = new FunctionalView

  it 'should be able to toggle to different classes', ->
    expect(functionalView.hasClass('info')).toBeTruthy()

    functionalView.find('[data-functional=console]').click()

    expect(functionalView.hasClass('console')).toBeTruthy()
