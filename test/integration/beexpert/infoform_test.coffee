hlpr = require '/test/ui-helper'
data = require '/test/data/all'
M = require 'scripts/beexpert/Models'
C = require 'scripts/beexpert/Collections'
V = require 'scripts/beexpert/Views'

pageData = {}

describe 'BeExpert:Views InfoFormView =>', ->

  before -> hlpr.setInitApp '/scripts/beexpert/Router'
  afterEach -> hlpr.cleanTearDown @
  beforeEach ->
    hlpr.cleanSetup @, data.fixtures.beexpert
    @defaultData = _id: null, homepage: 'http://home.co', brief: 'test', rate: 40, status: 'busy', hours: '3-5'
    @expert = new M.Expert()
    @tags = new C.Tags( data.tags )
    @viewData = model: @expert, tags: @tags


  it 'on load sets correct homepage, hours, rate & status selected', ->
    d = @defaultData
    @stubs.expertFetch = sinon.stub M.Expert::, 'fetch', -> @set d

    initApp { session: data.users[3] }

    v = router.app.infoFormView
    expect( v.$('#homepage').val() ).to.be.equal 'http://home.co'
    expect( v.elm('hours').val() ).to.equal '3-5'
    expect( v.$('#rate40').is(':checked') ).to.be.true
    expect( v.$('#rate40').prev().hasClass('checked') ).to.be.true
    expect( v.$('#statusBusy').is(':checked') ).to.be.true
    expect( v.$('#statusBusy').prev().hasClass('checked') ).to.be.true

  it 'validation on brief fires with brief', ->
    d = @defaultData
    delete d.brief
    @stubs.expertFetch = sinon.stub M.Expert::, 'fetch', -> @set d

    initApp { session: data.users[3] }
    v = router.app.infoFormView
    v.$('.save').click()
    expect( hlpr.showsError(v.$("#brief")) ).to.be.true

  it 'validation on tags fires with no tags', ->
    d = @defaultData
    delete d.tags
    @stubs.expertFetch = sinon.stub M.Expert::, 'fetch', -> @set d
    initApp { session: data.users[3] }
    v = router.app.infoFormView
    v.model.set @defaultData
    v.$('.save').click()
    errorMSG = v.$('.controls-tags .error-message')
    expect(errorMSG.length).to.equal 1

  it 'adding a tags leaves homepage, brief, rate, hours & status as is', ->
    d = @defaultData
    delete d.tags
    @stubs.expertFetch = sinon.stub M.Expert::, 'fetch', -> @set d
    @stubs.tagsFetch = sinon.stub C.Tags::, 'fetch', -> @set data.tags; @trigger 'sync'

    initApp { session: data.users[3] }

    v = router.app.infoFormView
    router.navTo 'info'
    v.$('#homepage').val 'airtest.com'
    v.$('#brief').val 'test don change it!'
    v.$('#hours').val '5-10'
    v.$('#rate10').click()
    v.$('#statusBusy').click()
    expect(v.model.get('tags')).to.equal undefined

    d = v.getViewData()
    expect(d.homepage).to.equal 'airtest.com'
    expect(d.brief).to.equal 'test don change it!'
    expect(d.hours).to.equal '5-10'
    expect(d.rate).to.equal '10'
    expect(d.status).to.equal 'busy'

    v.$('.autocomplete').val('c').trigger('input').trigger('input')
    $(v.$('.tt-suggestion')[0]).click()
    expect( v.model.get('tags').length ).to.equal 1

    d2 = v.getViewData()
    expect(d2.homepage).to.equal 'airtest.com'
    expect(d2.brief).to.equal 'test don change it!'
    expect(d2.hours).to.equal '5-10'
    expect(d2.rate).to.equal '10'
    expect(d2.status).to.equal 'busy'


  # it 'strips http:// & https:// from websites & urls', ->