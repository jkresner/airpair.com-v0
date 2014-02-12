Tags = require('/scripts/request/Collections').Tags
f    = data.fixtures

storySteps = [
  { app:'request', usr:'sirramongabriel', frag: '#', fixture: f.request, pageData: {} }
  { app:'inbound', usr:'admin', frag: '#', fixture: f.inbound, pageData: { experts: data.experts, tags: data.tags } }
  { app:'review', usr:'sirramongabriel', frag: '#rId', fixture: f.review, pageData: {} }
]

testNum = -1
request = data.requests[9]  #ProjectRamon Request

describe "Stories: Ramon Porter", ->

  before (done) ->
    @tagsFetch = sinon.stub Tags::, 'fetch', -> @set data.tags; @trigger 'sync'
    done()

  after -> @tagsFetch.restore()

  beforeEach (done) ->
    testNum++
    hlpr.cleanSetup @, storySteps[testNum].fixture
    window.location = storySteps[testNum].frag.replace 'rId', @rId
    hlpr.setInitApp @, "/scripts/#{storySteps[testNum].app}/Router"
    hlpr.setSession storySteps[testNum].usr, =>
      # $log 'app', storySteps[testNum].app, storySteps[testNum].pageData
      initApp(storySteps[testNum].pageData, done)

  afterEach ->
    hlpr.cleanTearDown @

  it 'can create request by customer', (done) ->
    {infoFormView,requestFormView} = @app
    @app.company.once 'sync', =>
      infoFormView.elm('name').val 'Ramon'
      infoFormView.elm('url').val ''
      infoFormView.elm('about').val 'Lifetime student. Looking to learn the following Ruby related disciplines with the goal of being qualified to apply for junior ruby/rails developer career opportunities'

      @app.company.once 'sync', =>
        requestFormView.$('.autocomplete').val('ruby').trigger('input')
        $(requestFormView.$('.tt-suggestion')[0]).click()
        requestFormView.elm('brief').val request.brief
        requestFormView.$('#pricingOpensource').click()
        requestFormView.$('#budget2').click()
        requestFormView.elm('availability').val request.availability

        @app.request.once 'sync', =>
          @rId = @app.request.id
          done()

        requestFormView.$('.save').click()
      infoFormView.$('.save').click()

  it 'can suggest experts as admin', (done) ->
    rv = @app.requestView

    @app.requests.once 'sync', =>
      router.navTo "#request/#{@rId}"
      @app.selected.once 'sync', saveSuggestions

    saveSuggestions = =>
      @app.selected.save { suggested: request.suggested }, success: (model) =>
        expect( @app.selected.get('suggested').length ).to.equal 8
        done()

  it 'can review experts and book hours as customer with PayPal', (done) ->
    @timeout 10000
    {request,requestView} = @app
    request.once 'sync', =>
      v = requestView
      expect( v.$('.suggested .suggestion').length ).to.equal 5
      expect( v.$('.book-actions').is(':visible') ).to.equal true

      v.$('.book-actions .button').click()
      router.navTo v.$('.book-actions .button').attr('href')

      bv = @app.bookView
      expect( bv.$el.is(':visible') ).to.equal true
      expect( bv.$('#pay').is(':visible') ).to.equal false

      $bookableExperts = bv.$('.bookableExpert')
      expect( $bookableExperts.length ).to.equal 5
      $evanR = $($bookableExperts[4])
      $evanR.find('[name=qty]').val('2').trigger 'change'
      expect( bv.$('#pay').is(':visible') ).to.equal true

      bv.model.once 'sync', (model) =>
        expect( model.get('total') ).to.equal 180
        done()

      bv.$('.payPalpal').click()
