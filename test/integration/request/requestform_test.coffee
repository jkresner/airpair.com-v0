M = require '/scripts/request/Models'
C = require '/scripts/request/Collections'
V = require '/scripts/request/Views'

describe 'Request:Views RequestFormView =>', ->

  before -> hlpr.setInitApp @, '/scripts/request/Router'
  afterEach -> hlpr.cleanTearDown @
  beforeEach ->
    hlpr.cleanSetup @, data.fixtures.request
    @defaultData = brief: 'test brief', availability: "I am available", budget: 30, pricing: 'private', hours: '1', company: { contacts: [ { fullName: "test" } ] }
    @request = new M.Request()
    @tags = new C.Tags( data.tags )
    @stubs.companyFetch = sinon.stub M.Company::, 'fetch', -> @set data.companys[0]
    @stubs.tagsFetch = sinon.stub C.Tags::, 'fetch', -> @set data.tags; @trigger 'sync'
    initApp session: data.users[3]
    router.navTo 'request'

  it 'on load sets correct {budget, pricing} radios, {brief, availability}', ->
    v = router.app.requestFormView
    v.model.set @defaultData
    expect( v.$('#budget2').is(':checked') ).to.be.true
    expect( v.$('#budget2').prev().hasClass('checked') ).to.be.true
    expect( v.$('#pricingPrivate').is(':checked') ).to.be.true
    expect( v.$('#pricingPrivate').prev().hasClass('checked') ).to.be.true
    expect( v.elm('availability').val() ).to.be.equal "I am available"
    expect( v.elm('brief').val() ).to.be.equal "test brief"
    expect( v.elm('hours').val() ).to.equal '1'

  it 'validation on availability fires with no availability', ->
    v = router.app.requestFormView
    delete @defaultData.availability
    v.model.set @defaultData
    v.$('.save').click()
    expect( hlpr.showsError(v.elm("availability")) ).to.be.true

  it 'validation on brief fires with brief', ->
    v = router.app.requestFormView
    delete @defaultData.brief
    v.model.set @defaultData
    v.$('.save').click()
    expect( hlpr.showsError(v.$("[name=brief]")) ).to.be.true

  it 'validation on tags fires with no tags', ->
    v = router.app.requestFormView
    delete @defaultData.tags
    v.model.set @defaultData
    v.$('.save').click()
    errorMSG = v.$('.controls-tags .error-message')
    expect(errorMSG.length).to.equal 1

  it 'validation error goes away when a tag is chosen', ->
    v = router.app.requestFormView
    delete @defaultData.tags
    v.model.set @defaultData
    v.$('.save').click()
    expect( v.$('.controls-tags .error-message').length ).to.equal 1
    v.model.set 'tags', [data.tags[0]]
    expect( v.$('.controls-tags .error-message').length ).to.equal 0

  it 'can select a tag', ->
    v = router.app.requestFormView
    expect( v.$('.tt-dropdown-menu').is(':visible') ).to.be.false
    v.$('.autocomplete').val('c').trigger('input')
    expect( v.$('.tt-dropdown-menu').is(':visible') ).to.be.true
    expect( v.model.get('tags') ).to.equal undefined
    $(v.$('.tt-suggestion')[0]).click()
    expect( v.model.get('tags').length ).to.equal 1
    expect( v.$('.selected .label-tag').length ).to.equal 1

  it 'can remove a tag', ->
    v = router.app.requestFormView
    $('.autocomplete').val('c').trigger('input').trigger('input')
    expect( v.model.get('tags') ).to.equal undefined
    $(v.$('.tt-suggestion')[0]).click()
    $(v.$('.selected .label-tag')[0]).find('.rmTag').click()
    expect( v.model.get('tags').length ).to.equal 0


  it 'can add a new stackoverflow tag', (done) ->
    v = router.app.requestFormView
    $('.autocomplete').val('zzzzzd').trigger('input').trigger('input')
    expect( v.$('.tt-suggestions .new').length ).to.equal 1
    newLink = $(v.$('.tt-suggestions .new')[0])
    expect( v.$('.autocomplete').is(':visible') ).to.be.true
    expect( v.$('#tagNewForm').is(':visible') ).to.be.false
    newLink.click()
    expect( v.$('.autocomplete').is(':visible') ).to.be.false
    expect( v.$('#tagNewForm').is(':visible') ).to.be.true
    expect( v.elm('nameStackoverflow').val() ).to.equal 'zzzzzd'
    expect( v.mget('tags') ).to.equal undefined
    v.elm('nameStackoverflow').val('c')
    v.$('.save-so').click()

    tagSaved = =>
      expect( v.mget('tags').length ).to.equal 1
      expect( v.mget('tags')[0].short ).to.equal 'c'
      expect( v.$('.selected .label-tag').length ).to.equal 1
      expect( v.$('.autocomplete').is(':visible') ).to.be.true
      expect( v.$('#tagNewForm').is(':visible') ).to.be.false
      done()

    v.tags.once 'sync', tagSaved, @

  it 'display error when trying to add invalid stackoverflow tag', (done) ->
    v = router.app.requestFormView
    $('.autocomplete').val('zxxx').trigger('input').trigger('input')
    newLink = $(v.$('.tt-suggestions .new')[0])
    newLink.click()
    expect( v.model.get('tags') ).to.equal undefined
    v.$('.save-so').click()

    tagSavedFailed = =>
      expect( v.model.get('tags') ).to.equal undefined
      expect( v.$('.selected .label-tag').length ).to.equal 0
      expect( v.$('.autocomplete').is(':visible') ).to.be.false
      expect( v.$('#tagNewForm').is(':visible') ).to.be.true
      errorMSG = v.$('#tagsInput .error-message')
      expect(errorMSG.length).to.equal 1
      done()

    v.tagsInput.newForm.model.once 'error', tagSavedFailed, @

  # *** Now only checks for required
  # it 'filling in all details with less than 250 char brief does not wipe brief', ->
  #   v = router.app.requestFormView
  #   v.$('.autocomplete').val('c').trigger('input')
  #   $(v.$('.tt-suggestion')[0]).click()
  #   v.elm('brief').val 'baaaaah'
  #   v.elm('availability').val 'now biatch!'
  #   v.$('.save').click()

  #   expect( hlpr.showsError(v.elm("brief")) ).to.be.true
  #   expect( v.elm("brief").val() ).to.equal 'baaaaah'


  it 'choosing a tag doesnt effect other field', ->
    v = router.app.requestFormView

    v.elm('brief').val 'baaaaah'
    v.elm('availability').val 'now biatch!2'
    v.$('.autocomplete').val('c').trigger('input')
    $(v.$('.tt-suggestion')[0]).click()

    expect( v.elm("brief").val() ).to.equal 'baaaaah'
    expect( v.elm("availability").val() ).to.equal 'now biatch!2'

  # it 'on server error, error message renders', ->
  #   expect(false).to.be.true
