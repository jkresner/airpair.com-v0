Tags = require('/scripts/request/Collections').Tags
f = data.fixtures

storySteps = [
  { app:'settings', usr:'bchristie', frag: '#', fixture: f.settings, pageData: { stripePK: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl' } }
  { app:'request', usr:'bchristie', frag: '#', fixture: f.request, pageData: {} }
  { app:'inbound', usr:'admin', frag: '#', fixture: f.inbound, pageData: { experts: data.experts, tags: data.tags } }
  { app:'review', usr:'bchristie', frag: '#rId', fixture: f.review, pageData: {} }
  { app:'orders', usr: 'admin', frag: '#', fixture: f.orders, pageData: {} }
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
        expect( @app.selected.get('suggested').length ).to.equal 2
        done()

  it 'can review experts and book hours as customer with stripe', (done) ->
    {request,settings,requestView} = @app

    synced = 0
    settings.once 'sync', => synced++; if synced == 2 then test()
    request.once 'sync', => synced++; if synced == 2 then test()

    test = =>
      v = requestView
      expect( v.$('.suggested .suggestion').length ).to.equal 2
      expect( v.$('.book-actions').is(':visible') ).to.equal true

      v.$('.book-actions .btn').click()
      router.navTo v.$('.book-actions .btn').attr('href')

      bv = @app.bookView

      expect( bv.$el.is(':visible') ).to.equal true
      expect( bv.$('#pay').is(':visible') ).to.equal false

      $bookableExperts = bv.$('.bookableExpert')
      expect( $bookableExperts.length ).to.equal 2
      $paulC = $($bookableExperts[0])
      $steveM = $($bookableExperts[1])

      $paulC.find('[name=qty]').val('2').trigger 'change'
      expect( bv.$('#pay').is(':visible') ).to.equal true
      $steveM.find('[name=qty]').val('1').trigger 'change'

      $log 'payStripe', bv.$('.payStripe'), bv.$('.payStripe').is(':visible')
      expect( bv.$('.payStripe').is(':visible') ).to.equal true

      bv.model.once 'sync', (model) =>
        expect( model.get('total') ).to.equal 180 + 90
        done()

      bv.$('.payStripe').click()

  it 'can pay out customer\'s experts individually as admin', (done) ->
    this.timeout 20000
    {orders, ordersView} = @app
    ###
    wait for orders to sync, get bruce's order
    click payout for each expert
    wait for the order model to sync
    check that everyone is successfully paid out
    ###
    orders.once 'sync', =>
      window.orders = orders
      order = (orders.models.filter (o) => o.get('requestId') == @rId)[0]

      lineIds = order.get('lineItems').map (l) -> l._id
      expect(lineIds.length).to.equal 2
      selectors = lineIds.map (id) => ".payOutPaypalSingle[data-id=#{id}]"
      buttons = $ selectors
      expect(buttons.length).to.equal 2
      expect(order.get('paymentStatus')).to.equal 'received'

      order.once 'sync', (model) =>
        # expect that the first expert re-renders to say "paidout"
        el = $ "[data-id=#{lineIds[0]}]"
        expect(el.length).to.equal 1
        expect(el.hasClass('paidout')).to.equal true
        expect(order.get('paymentStatus')).to.equal 'received'

        order.once 'sync', (model) =>
          # make sure the first expert is still paidout
          el = $ "[data-id=#{lineIds[0]}]"
          expect(el.length).to.equal 1
          expect(el.hasClass('paidout')).to.equal true

          # make sure the second expert is now paidout
          el = $ "[data-id=#{lineIds[1]}]"
          expect(el.length).to.equal 1
          expect(el.hasClass('paidout')).to.equal true

          # check the model knows it is paid out
          expect(order.get('paymentStatus')).to.equal "paidout"
          expect(order.get('payouts').length).to.equal 2
          expect(order.get('payouts')[0].req).to.be.a 'object'
          expect(order.get('payouts')[0].res).to.be.a 'object'
          expect(order.get('payouts')[1].req).to.be.a 'object'
          expect(order.get('payouts')[1].res).to.be.a 'object'
          done()

        $(selectors[1]).click() # need to query for it again b/c of re-render

      $(selectors[0]).click()
