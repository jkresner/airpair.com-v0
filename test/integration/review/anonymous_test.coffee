M = require '/scripts/ap/review/Models'
C = require '/scripts/ap/review/Collections'
V = require '/scripts/ap/review/Views'


describe "Review: anonymous", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/ap/review/Router'
    hlpr.setSession 'jk', =>
      $.post('/api/requests', data.requests[7]).done (r) =>
        @r = r
        hlpr.setSession 'anon', done

  beforeEach ->
    window.location = "#"+@r._id
    hlpr.cleanSetup @, data.fixtures.review

  afterEach ->
    hlpr.cleanTearDown @

  it 'review an id that does not exist', (done) ->
    window.location = "#"+@r._id.replace '5', '4'
    initApp session: { authenticated: false }

    rv = @app.requestView
    @app.request.once 'error', =>
      m = rv.request
      expect( $('#request').is(':visible') ).to.equal false
      expect( $('#empty').is(':visible') ).to.equal true
      done()

  it 'when reviewing as anonymous user', (done) ->
    initApp session: { authenticated: false }
    rv = @app.requestView

    rv.request.once 'sync', =>
      m = rv.request
      # should not get experts in request
      expect( m.has 'budget' ).to.equal false
      expect( m.has 'suggested' ).to.equal false
      expect( m.has 'events' ).to.equal false

      expect( rv.$('#expertReviewForm').is(':empty') ).to.equal true
      expect( rv.$('#expertReviewDetail').is(':empty') ).to.equal true
      expect( rv.$('#customerReview').is(':empty') ).to.equal true
      expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal false
      expect( rv.$('a.createProfile').is(':visible') ).to.equal true
      done()

  it '[preloaded] when reviewing as anonymous user', (done) ->
    initApp request: @r, session: { authenticated: false }
    rv = @app.requestView

    m = rv.request

    expect( rv.$('#expertReviewForm').is(':empty') ).to.equal true
    expect( rv.$('#expertReviewDetail').is(':empty') ).to.equal true
    expect( rv.$('#customerReview').is(':empty') ).to.equal true
    expect( rv.$('#notExpertOrCustomer').is(':empty') ).to.equal false
    expect( rv.$('a.createProfile').is(':visible') ).to.equal true
    done()

  # it "when click be expert should take to be expert page", (done) ->
    # @stubs.requestFetch = sinon.stub M.Company::, 'fetch', -> @set data.companys[0]

  # it "when click signin should return to exact review page", (done) ->
  #   expect(false).to.equal true
  #   done()
