{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'
data = require './../../data/all'
M = require '/scripts/review/Models'
C = require '/scripts/review/Collections'
V = require '/scripts/review/Views'


fixture = "<div id='detail' class='route'><div id='request'></div></div>"


describe "Review page: customer", ->

  before (done) ->
    hlpr.set_initApp '/scripts/review/Router'
    hlpr.setSession 'jk', =>
      $.post('/api/requests',data.requests[7]).done (r) =>
        @r = r
        done()

  beforeEach ->
    window.location = "#"+@r._id
    hlpr.clean_setup @, fixture
    customer = data.users[1] # JK
    initApp session: customer
    @router = window.router

  afterEach ->
    # hlpr.clean_tear_down @


  it "when reviewing as customer & expert hasn't replied", (done) ->
    rv = @router.app.requestView
    req = rv.request
    req.once 'sync', =>

      expect( req.has 'budget' ).to.equal true
      expect( req.has 'suggested' ).to.equal true

      expect( rv.$('#expertReviewForm').is(':empty') ).to.equal true
      expect( rv.$('#expertReviewDetail').is(':empty') ).to.equal true
      expect( rv.$('#customerReview').is(':empty') ).to.equal false
      expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal true

      expect( rv.customerReviewView.$('.label-waiting').is(':visible') ).to.equal true

      done()


  it "when reviewing as customer & expert has replied", (done) ->
    rv = @router.app.requestView
    req = rv.request
    req.once 'sync', =>
      suggestion = _.extend(req.get('suggested')[0], data.requestSuggested[0])
      req.set 'suggested', [suggestion]
      req.trigger 'change'
      expect( req.has 'budget' ).to.equal true
      expect( req.has 'suggested' ).to.equal true

      expect( rv.$('#expertReviewForm').is(':empty') ).to.equal true
      expect( rv.$('#expertReviewDetail').is(':empty') ).to.equal true
      expect( rv.$('#customerReview').is(':empty') ).to.equal false
      expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal true

      expect( rv.customerReviewView.$('.label-waiting').is(':visible') ).to.equal false
      expect( rv.customerReviewView.$('.label-available').is(':visible') ).to.equal true

      expect( rv.customerReviewView.$('.feedbackForAirpair').is(':visible') ).to.equal false

      done()