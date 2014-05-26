M = require '/scripts/ap/review/Models'
C = require '/scripts/ap/review/Collections'
V = require '/scripts/ap/review/Views'


describe "Review: customer", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/ap/review/Router'
    hlpr.setSession 'jk', =>
      $.post('/api/requests',data.requests[7]).done (r) =>
        @r = r
        done()

  beforeEach ->
    window.location = "#"+@r._id
    hlpr.cleanSetup @, data.fixtures.review
    customer = data.users[1] # JK
    initApp session: customer

  afterEach ->
    hlpr.cleanTearDown @


  it "when reviewing as customer & expert hasn't replied", (done) ->
    rv = @app.requestView
    req = rv.request
    req.once 'change', =>

      expect( req.has 'budget' ).to.equal true
      expect( req.has 'suggested' ).to.equal true

      expect( rv.$('#expertReviewForm').is(':empty') ).to.equal true
      expect( rv.$('#expertReviewDetail').is(':empty') ).to.equal true
      expect( rv.$('#customerReview').is(':empty') ).to.equal false
      expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal true

      # 10/6/13 Removed waiting experts from suggestions view
      # expect( rv.customerReviewView.$('.label-waiting').is(':visible') ).to.equal true

      done()


  it "when reviewing as customer & expert has replied", (done) ->
    rv = @app.requestView
    req = rv.request
    req.once 'change', =>
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
