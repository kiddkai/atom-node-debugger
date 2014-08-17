FunctionalView = require '../lib/functional-view'

describe 'Functional View', ->

  functionalView = null

  beforeEach ->
    functionalView = new FunctionalView

  it 'should be able to toggle to different classes', ->
    expect(functionalView.hasClass('console')).toBeTruthy()

    functionalView.find('[data-functional=debug]').click()
    expect(functionalView.hasClass('debug')).toBeTruthy()
    expect(functionalView.hasClass('console')).toBeFalsy()

    functionalView.find('[data-functional=frames]').click()
    expect(functionalView.hasClass('debug')).toBeFalsy()
    expect(functionalView.hasClass('console')).toBeFalsy()
    expect(functionalView.hasClass('frames')).toBeTruthy()

    functionalView.find('[data-functional=console]').click()
    expect(functionalView.hasClass('console')).toBeTruthy()


  it 'should be able to toggle the selected', ->
    functionalView.find('[data-functional=debug]').click()
    expect(functionalView.find('.selected').data('functional')).toBe('debug')

    functionalView.find('[data-functional=frames]').click()
    expect(functionalView.find('.selected').data('functional')).toBe('frames')

    functionalView.find('[data-functional=console]').click()
    expect(functionalView.find('.selected').data('functional')).toBe('console')
