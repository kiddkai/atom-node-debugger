FunctionalView = require '../lib/functional-view'

describe 'Functional View', ->

  functionalView = null

  beforeEach ->
    functionalView = new FunctionalView

  it 'should be able to toggle to different classes', ->
    expect(functionalView.hasClass('console')).toBeTruthy()

    functionalView.find('[data-functional=breakpoint]').click()
    expect(functionalView.hasClass('breakpoint')).toBeTruthy()
    expect(functionalView.hasClass('console')).toBeFalsy()

    functionalView.find('[data-functional=frame]').click()
    expect(functionalView.hasClass('breakpoint')).toBeFalsy()
    expect(functionalView.hasClass('console')).toBeFalsy()
    expect(functionalView.hasClass('frame')).toBeTruthy()

    functionalView.find('[data-functional=console]').click()
    expect(functionalView.hasClass('console')).toBeTruthy()


  it 'should be able to toggle the selected', ->
    functionalView.find('[data-functional=breakpoint]').click()
    expect(functionalView.find('.selected').data('functional')).toBe('breakpoint')

    functionalView.find('[data-functional=frame]').click()
    expect(functionalView.find('.selected').data('functional')).toBe('frame')

    functionalView.find('[data-functional=console]').click()
    expect(functionalView.find('.selected').data('functional')).toBe('console')
