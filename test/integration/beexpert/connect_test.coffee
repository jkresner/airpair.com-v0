{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'
M = require 'scripts/beexpert/Models'
C = require 'scripts/beexpert/Collections'
V = require 'scripts/beexpert/Views'

data =
  users: require './../../data/users'
  experts: require './../../data/experts'
  tags: require './../../data/tags'

fixture = """<div id='welcome' class='route'>welcome</div>
          <div id='connect' class='route'><div id="connectForm"></div></div>
          <div id="info" class="route">info</div>"""
pageData = {}

describe 'BeExpert:Views ConnectView =>', ->

  before -> hlpr.set_initApp '/scripts/beexpert/Router'
  afterEach -> hlpr.clean_tear_down @
  beforeEach -> hlpr.clean_setup @, fixture


  it 'can continue with fabian user details', (done) ->
    @stubs.expertFetch = sinon.stub M.Expert::, 'fetch', -> @set {}
    @stubs.success = sinon.stub V.ConnectView::, 'renderSuccess', ->

    initApp { session: data.users[3] }

    v = router.app.connectView
    v.render()
    expect( v.$('.save').length ).to.equal 1
    expect( v.$('#mininumConnect').length ).to.equal 0
    v.model.on 'sync', =>
      $log '@', @, @stubs.success
      expect(@stubs.success.calledOnce).to.be.true
      done()

    v.$('.save').click()


  it 'cannot save expert Jeffrey Camealy without username (v0.3 upgrade)', (done) ->
    @stubs.expertFetch = sinon.stub M.Expert::, 'fetch', -> @set data.experts[5];

    initApp { session: data.users[4] }

    v = router.app.connectView
    v.render()
    expect( v.mget('username') ).to.equal undefined
    expect( v.$('.save').length ).to.equal 0
    expect( v.$('#mininumConnect').is(':visible') ).to.be.true
    done()