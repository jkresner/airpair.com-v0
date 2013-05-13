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

describe 'BeExpert:Views ConnectView =>', ->

  before -> @SPA = hlpr.set_initSPA '/scripts/beexpert/App'
  afterEach -> hlpr.clean_tear_down @
  beforeEach ->
    hlpr.clean_setup @, fixture
    @session = new M.User()
    @expert = new M.Expert()
    @viewData = model: @expert, session: @session


  it 'can continue with fabian user details', (done) ->
    @stubs.success = sinon.stub V.ConnectView::, 'renderSuccess', ->
    @viewData.session.set data.users[3]
    v = new V.ConnectView @viewData
    v.render()  # we call it explicitly

    onSaved = =>
      expect(@stubs.success.calledOnce).to.be.true
      done()

    expect( v.$('.save').length ).to.equal 1
    expect( v.$('#mininumConnect').length ).to.equal 0

    v.model.on 'sync', onSaved, @
    v.$('.save').click()


  it 'cannot save expert Jeffrey Camealy without username (v0.3 upgrade)', ->
    @viewData.session.set data.users[4]
    @viewData.model.set data.experts[5]

    v = new V.ConnectView @viewData
    v.render()  # we call it explicitly

    expect( v.mget('username') ).to.equal undefined
    expect( v.$('.save').length ).to.equal 0
    expect( v.$('#mininumConnect').is(':visible') ).to.be.true