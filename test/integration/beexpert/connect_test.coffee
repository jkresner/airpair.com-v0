M = require 'scripts/ap/beexpert/Models'
C = require 'scripts/ap/beexpert/Collections'
V = require 'scripts/ap/beexpert/Views'

pageData = {}

describe 'BeExpert:Views ConnectView =>', ->

  before -> hlpr.setInitApp @, '/scripts/ap/beexpert/Router'
  afterEach -> hlpr.cleanTearDown @
  beforeEach -> hlpr.cleanSetup @, data.fixtures.beexpert


  it 'can continue with fabian user details', (done) ->
    @stubs.expertFetch = sinon.stub M.Expert::, 'fetch', -> @set {}
    @stubs.success = sinon.stub V.ConnectView::, 'renderSuccess', ->

    initApp { session: data.users[3] }

    v = router.app.connectView
    v.render()
    expect( v.$('.save').length ).to.equal 1
    expect( v.$('#mininumConnect').length ).to.equal 0
    v.model.on 'sync', =>
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



  it 'can continue w no google image and twitter account using jan petrovic user details', (done) ->
    @stubs.expertFetch = sinon.stub M.Expert::, 'fetch', -> @set {}
    @stubs.success = sinon.stub V.ConnectView::, 'renderSuccess', ->

    initApp { session: data.users[11] }

    v = router.app.connectView
    v.render()
    expect( v.$('.save').length ).to.equal 1
    expect( v.$('#mininumConnect').length ).to.equal 0
    v.model.on 'sync', =>
      expect(@stubs.success.calledOnce).to.be.true
      done()

    v.$('.save').click()
