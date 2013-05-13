{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'
M = require 'scripts/beexpert/Models'
C = require 'scripts/beexpert/Collections'
V = require 'scripts/beexpert/Views'

data =
  users: require './../../data/users'
  experts: require './../../data/experts'
  tags: require './../../data/tags'

fixture = """<div id='welcome' class='main'>welcome</div>
      <div id='connectForm' class='main'>info</div>
       <div id="infoForm"></div>"""

describe 'BeExpert:Views InfoFormView =>', ->

  before -> @SPA = hlpr.set_initSPA '/scripts/beexpert/App'
  afterEach -> hlpr.clean_tear_down @
  beforeEach ->
    hlpr.clean_setup @, fixture
    @defaultData = homepage: 'http://home.co', brief: 'test', rate: 40, status: 'busy', hours: '3-5'
    @expert = new M.Expert()
    @tags = new C.Tags( data.tags )
    @viewData = model: @expert, tags: @tags

  it 'on load sets correct homepage, hours, rate & status selected', ->
    v = new V.InfoFormView @viewData
    v.model.set @defaultData
    expect( v.$('#homepage').val() ).to.be.equal 'http://home.co'
    expect( v.$('[name=hours]').val() ).to.equal '3-5'
    expect( v.$('#rate40').is(':checked') ).to.be.true
    expect( v.$('#rate40').prev().hasClass('checked') ).to.be.true
    expect( v.$('#statusBusy').is(':checked') ).to.be.true
    expect( v.$('#statusBusy').prev().hasClass('checked') ).to.be.true

  it 'validation on brief fires with brief', ->
    delete @defaultData.brief
    v = new V.InfoFormView @viewData
    v.model.set @defaultData
    v.$('.save').click()
    expect( hlpr.showsError(v.$("#brief")) ).to.be.true

  it 'validation on tags fires with no tags', ->
    delete @defaultData.tags
    v = new V.InfoFormView @viewData
    v.model.set @defaultData
    v.$('.save').click()
    errorMSG = v.$('.controls-tags .error-message')
    expect(errorMSG.length).to.equal 1

  it 'adding a tags leaves homepage, brief, rate, hours & status as is', ->
    delete @defaultData.tags
    v = new V.InfoFormView @viewData
    v.model.set @defaultData
    v.tags.trigger 'sync'
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