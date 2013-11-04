Tags = require('/scripts/request/Collections').Tags
f = data.fixtures

storySteps = [
  { app:'settings', usr:'bchristie', frag: '#', fixture: f.settings, pageData: { stripePK: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl' } }  
  { app:'request', usr:'bchristie', frag: '#', fixture: f.request, pageData: {} }
  { app:'inbound', usr:'admin', frag: '#', fixture: f.inbound, pageData: { experts: data.experts, tags: data.tags } }
  { app:'review', usr:'bchristie', frag: '#rId', fixture: f.review, pageData: {} }
]

testNum = -1
request = data.requests[10]  #Bruce Christie

describe "Stories: Bruce Christie", ->

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

  it 'can create stripe settings', (done) ->
    psv = @app.paymentSettingsView
    rv = @app.stripeRegisterView

    rv.model.once 'sync', =>

      expect( rv.$el.is(':visible') ).to.equal false
      psv.$('.setup').click()
      router.navTo psv.$('.setup').attr('href') #not sure why had to do this        

      rv.$('[data-stripe=number]').val("4242 4242 4242 4242")
      rv.$('[data-stripe=cvc]').val("424")
      rv.$('[data-stripe=exp-month]').val("10")
      rv.$('[data-stripe=exp-year]').val("14")

      rv.model.once 'sync', =>
        pMethods = rv.model.get('paymentMethods')
        expect(pMethods.length).to.equal 1
        expect(pMethods[0].type).to.equal 'stripe'

        expect(rv.model.has('stripeCreate')).to.equal false
        done()

      rv.$('button').click()


  it 'can create request by customer', (done) ->
    {infoFormView,requestFormView} = @app
    @app.company.once 'sync', =>
      infoFormView.elm('name').val 'Bruce Christie'
      infoFormView.elm('url').val ''
      infoFormView.elm('about').val 'Bah desc of the compnay is the momnayasdf asdf  asdf as df asdf as df asd fa sdf'

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
      router.navTo "##{@rId}"

      @app.selected.save { suggested: request.suggested }, success: (model) =>
        expect( @app.selected.get('suggested').length ).to.equal 1
        done()

  it 'can review experts and book hours as customer with stripe', (done) ->
    {request,settings,requestView} = @app
    settings.once 'sync', =>
      v = requestView
      expect( v.$('.suggested .suggestion').length ).to.equal 1
      expect( v.$('.book-actions').is(':visible') ).to.equal true

      v.$('.book-actions .btn').click()
      router.navTo v.$('.book-actions .btn').attr('href')

      bv = @app.bookView

      expect( bv.$el.is(':visible') ).to.equal true
      expect( bv.$('#pay').is(':visible') ).to.equal false

      $bookableExperts = bv.$('.bookableExpert')
      expect( $bookableExperts.length ).to.equal 1
      $paulC = $($bookableExperts[0])
      $paulC.find('[name=qty]').val('2').trigger 'change'
      expect( bv.$('#pay').is(':visible') ).to.equal true
      $log 'payStripe', bv.$('.payStripe'), bv.$('.payStripe').is(':visible')
      expect( bv.$('.payStripe').is(':visible') ).to.equal true

      bv.model.once 'sync', (model) =>
        expect( model.get('total') ).to.equal 180
        done()

      bv.$('.payStripe').click()


