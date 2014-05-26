M = require '/scripts/ap/review/Models'
C = require '/scripts/ap/review/Collections'
V = require '/scripts/ap/review/Views'


describe "Review: signed in expert", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/ap/review/Router'
    hlpr.setSession 'jk', =>
      $.post('/api/requests', data.requests[7]).done (r) =>
        @r = r
        done()

  beforeEach ->
    window.location = "#"+@r._id
    hlpr.cleanSetup @, data.fixtures.review

  afterEach ->
    hlpr.cleanTearDown @


  # it "when reviewing as logged in user not assigned to request", (done) ->
  #   hlpr.setSession 'bearMountain', ->

  #   initApp session: data.users[4] # Jeffrey Camealy (not expert)
  #   rv = @app.requestView

  #   rv.request.once 'sync', =>
  #     m = rv.request
  #     $log 'rv.request', m.attributes

  #     expect( m.has 'budget' ).to.equal false
  #     expect( m.has 'suggested' ).to.equal false
  #     expect( m.has 'events' ).to.equal false
  #     expect( m.has 'owner' ).to.equal true
  #     expect( m.get 'owner' ).to.equal 'mi'

  #     expect( rv.$('#expertReviewForm').is(':empty') ).to.equal true
  #     expect( rv.$('#expertReviewDetail').is(':empty') ).to.equal true
  #     expect( rv.$('#customerReview').is(':empty') ).to.equal true
  #     expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal false
  #     expect( rv.$('a.claimRequest').is(':visible') ).to.equal true
  #     done()


  it "show review form when reviewing as suggestedExpert for 1st time", (done) ->
    hlpr.setSession 'artjumble', ->
    expert = data.users[5] # Steven Matthews (suggested)
    initApp session: expert
    rv = @app.requestView
    req = rv.request
    req.once 'sync', =>

      # expect( req.has 'budget' ).to.equal true
      expect( req.has 'suggested' ).to.equal true

      expect( rv.$('#expertReview').is(':empty') ).to.equal false
      expect( rv.$('#customerReview').is(':empty') ).to.equal true
      expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal true

      expect( rv.$('#expertReviewForm').is(':visible') ).to.equal true
      expect( rv.$('.expertMini pic').attr 'src' ).to.equal expert.pic

      expect( rv.$('#expertReviewDetail').is(':visible') ).to.equal false

      done()


  it "can review as suggestedExpert", (done) ->
    hlpr.setSession 'artjumble', ->
    expert = data.users[5] # Steven Matthews (suggested)
    initApp session: expert

    rv = @app.requestView
    v = rv.expertReviewView
    req = rv.request

    req.once 'sync', =>

      v.render = _.wrap v.render, (fn, args) ->
        fn.call @, args
        d = req.attributes.suggested[0]
        expect( true ).to.equal true
        # expect( d.expertRating ).to.equal 2
        # expect( d.expertFeedback ).to.equal 'this is an awesome test request this is an awesome test request'
        expect( d.expertStatus ).to.equal 'available'
        expect( d.expertComment ).to.equal 'siiiiic testing'
        expect( d.expertAvailability ).to.equal 'anytime!'

        expect( v.reviewFormView.$el.is(':visible') ).to.equal false
        expect( v.detailView.$el.is(':visible') ).to.equal true
        # expect( v.detailView.$('.feedbackForAirpair').is(':visible') ).to.equal true

        done()

      v.elm('agree').click()
      v.elm('payPalEmail').val 'expert02@airpair.com'
      # v.elm('expertRating').val 2
      # v.elm('expertFeedback').val 'this is an awesome test request this is an awesome test request'
      v.elm('expertStatus').val('available').trigger 'change'
      v.elm('expertComment').val 'siiiiic testing'
      v.elm('expertAvailability').val 'anytime!'
      v.$('.saveFeedback').click()

  # it "after reviewing as suggestedExpert should show reviewed screen filled out", (done) ->
  #   hlpr.setSession 'artjumble', ->
  #   expert = data.users[5] # Steven Matthews (suggested)
  #   initApp session: expert
  #   @router = window.router

  #   rv = @router.app.requestView
  #   v = rv.expertReviewView
  #   req = rv.request

  #   req.once 'sync', =>


  # it "when reviewing as suggestedExpert after already filling out form", (done) ->
  #   seeReviewFilledOut = true
  #   expect(seeReviewFilledOut).to.equal true
  #   done()
