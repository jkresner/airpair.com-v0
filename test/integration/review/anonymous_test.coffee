{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'
M = require '/scripts/review/Models'
C = require '/scripts/review/Collections'
V = require '/scripts/review/Views'

data =
  users: require './../../data/users'
  requests: require './../../data/requests'


fixture = "<div id='detail' class='route'><div id='request'></div></div>"


describe "Review page: anonymous", ->

  before (done) ->
    hlpr.set_initApp '/scripts/review/Router'
    hlpr.setSession 'jk', =>
      $.post('/api/requests',data.requests[7]).done (data) =>
        @rId = data._id
        hlpr.setSession 'anon', done

  beforeEach ->
    hlpr.clean_setup @, fixture
    initApp session: { authenticated: false }
    @router = window.router

  afterEach ->
    hlpr.clean_tear_down @


  it 'when reviewing anonymous user', (done) ->
    @router.navTo @rId
    rv = @router.app.requestView

    rv.model.on 'sync', =>
      m = rv.model
      # should not get experts in request
      expect( m.has 'budget' ).to.equal false
      expect( m.has 'suggested' ).to.equal false
      expect( m.has 'events' ).to.equal false

      expect( rv.$('#expertReview').is(':empty') ).to.equal true
      expect( rv.$('#customerReview').is(':empty') ).to.equal true
      expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal false
      expect( rv.$('a.createProfile').is(':visible') ).to.equal true
      done()



  # it "when click be expert should take to be expert page", (done) ->
    # @stubs.requestFetch = sinon.stub M.Company::, 'fetch', -> @set data.companys[0]

  # it "when click signin should return to exact review page", (done) ->
  #   expect(false).to.equal true
  #   done()