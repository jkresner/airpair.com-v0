{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'
M = require '/scripts/review/Models'
C = require '/scripts/review/Collections'
V = require '/scripts/review/Views'

data =
  users: require './../../data/users'
  requests: require './../../data/requests'


fixture = "<div id='detail' class='route'><div id='request'></div></div>"


describe "Review page: signed in expert", ->

  before (done) ->
    hlpr.set_initApp '/scripts/review/Router'
    hlpr.setSession 'jk', =>
      $.post('/api/requests',data.requests[7]).done (data) =>
        @rId = data._id
        done()

  beforeEach ->
    hlpr.clean_setup @, fixture

  afterEach ->
    # hlpr.clean_tear_down @

  it "when reviewing as logged in user not assigned to request", (done) ->
    initApp session: data.users[4] # Jeffrey Camealy (not expert)
    @router = window.router
    @router.navTo @rId
    rv = @router.app.requestView

    rv.model.on 'sync', =>
      m = rv.model

      # should not get experts in request
      # expect( m.has 'budget' ).to.equal true
      # expect( m.has 'suggested' ).to.equal true
      # expect( m.has 'events' ).to.equal false

      expect( rv.$('#expertReview').is(':empty') ).to.equal true
      expect( rv.$('#customerReview').is(':empty') ).to.equal true
      expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal false
      expect( rv.$('a.claimRequest').is(':visible') ).to.equal true
      done()


  it "when reviewing as suggestedExpert for first time", (done) ->
    initApp session: data.users[5] # Steven Matthews (suggested)
    @router = window.router
    @router.navTo @rId
    rv = @router.app.requestView

    rv.model.on 'sync', =>
      m = rv.model

      # should not get experts in request
      # expect( m.has 'budget' ).to.equal true
      expect( m.has 'suggested' ).to.equal true
      # expect( m.has 'events' ).to.equal false

      expect( rv.$('#expertReview').is(':empty') ).to.equal false
      expect( rv.$('#customerReview').is(':empty') ).to.equal true
      expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal true
      done()



  # it "after reviewing as suggestedExpert should show reviewed screen filled out", (done) ->
  #   seeReviewFilledOut = true
  #   expect(seeReviewFilledOut).to.equal true
  #   done()


  # it "when reviewing as suggestedExpert after already filling out form", (done) ->
  #   seeReviewFilledOut = true
  #   expect(seeReviewFilledOut).to.equal true
  #   done()


  # it "when reviewing as customer and expert hasn't replied", (done) ->
  #   seeWaitingForExpertReply = true
  #   expect(seeWaitingForExpertReply).to.equal true
  #   done()


  # it "when reviewing as customer and expert has replied", (done) ->
  #   seeReplyCommentsByExpert = true
  #   expect(seeReplyCommentsByExpert).to.equal true
  #   done()
