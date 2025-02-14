Tags = require('/scripts/ap/request/Collections').Tags
f    = data.fixtures

request = _.clone(data.requests[10])  #Bruce Christie

storySteps = [
  { app:'ap/settings/Router', usr:'bchristie', frag: '#', fixture: f.settings, pageData: { stripePK: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl' } }
  { app:'ap/request/Router', usr:'bchristie', frag: '#', fixture: f.request, pageData: {} }
  { app:'adm-old/pipeline/Router', usr:'admin', frag: '#', fixture: f.inbound, pageData: { experts: data.experts, tags: data.tags } }
  { app:'ap/review/Router', usr:'bchristie', frag: '#rId', fixture: f.review, pageData: {} }
  { app:'ap/schedule/Router', usr: 'admin', frag: '#/schedule/rId', fixture: f.callSchedule, pageData: { request: request, orders: data.orders[2] } }
  { app:'adm-old/orders/Router', usr: 'admin', frag: '#', fixture: f.orders, pageData: {} }
]

testNum = -1

describe "Stories: Bruce Christie", ->

  before (done) ->
    @tagsFetch = sinon.stub Tags::, 'fetch', -> @set data.tags; @trigger 'sync'
    done()

  after -> @tagsFetch.restore()

  beforeEach (done) ->
    testNum++
    hlpr.cleanSetup @, storySteps[testNum].fixture
    window.location = storySteps[testNum].frag.replace 'rId', @rId
    hlpr.setInitApp @, "/scripts/#{storySteps[testNum].app}"
    hlpr.setSession storySteps[testNum].usr, =>
      # $log 'app', storySteps[testNum].app, storySteps[testNum].pageData
      initApp(storySteps[testNum].pageData, done)

  afterEach ->
    hlpr.cleanTearDown @

  it 'can create stripe settings', (done) ->
    @timeout 5000
    psv = @app.paymentSettingsView
    rv = @app.stripeRegisterView
    $log 'rv', rv.model
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
          request._id = @rId

          # we need the ID for the call scheduling story
          storySteps[4].pageData.request._id = @rId
          done()

        requestFormView.$('.save').click()
      infoFormView.$('.save').click()

  it 'can suggest experts as admin', (done) ->
    @timeout 5000
    rv = @app.requestView

    @app.requests.once 'sync', =>
      router.navTo "##{@rId}"
      @app.selected.once 'sync', saveSuggestions

    saveSuggestions = =>
      changes = { suggested: request.suggested, owner: request.owner }
      @app.selected.save changes, success: (model) =>
        expect( @app.selected.get('suggested').length ).to.equal 2
        expect( @app.selected.get('owner') ).to.equal 'jk'
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

      v.$('.book-actions .button').click()
      router.navTo v.$('.book-actions .button').attr('href')

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

      # $log 'payStripe', bv.$('.payStripe'), bv.$('.payStripe').is(':visible')
      expect( bv.$('.payStripe').is(':visible') ).to.equal true

      bv.model.once 'sync', (model) =>
        expect( model.get('total') ).to.equal 180 + 90
        done()

      bv.$('.payStripe').click()

  it 'can schedule a call as admin', (done) ->
    this.timeout 10000
    {request, orders, scheduleView} = @app
    v = scheduleView

    # radios = v.$('input:radio')
    # expect(radios.length).to.equal 1 # shouldnt show other expert b/c no hours

    # paul should be selected by default, b/c he's the only expert.
    # radios.first().click()

    type = v.elm('type')
    expect(type.length).to.equal 1
    expect(type.val()).to.equal 'opensource'

    # book two hours
    duration = v.elm('duration')
    expect(duration.length).to.equal 1
    expect(duration.val()).to.equal '1'
    duration.val(2)
    expect(duration.val()).to.equal '2'

    # date = v.elm('date')
    # expect(moment().format("DD MMM YYYY")).to.equal date.val()

    expectedTime = '16:30'
    v.elm('time').val('16:30')

    v.renderSuccess = -> # disable the redirect after save
    v.model.on 'sync', (model, resp) ->
      expect(v.model.get('errors')).to.equal undefined

      # the model is now a full request
      newCall = model.toJSON().calls[0]
      # mocha-phantom's Date string parsing seems different than node's.
      # expectedDatetime = new Date(date.val() + ' 16:30 PST').toISOString()
      # expect(newCall.datetime).to.equal expectedDatetime
      expect(v.model.get('time')).to.equal expectedTime
      expect(newCall.duration).to.equal 2
      expect(newCall.type).to.equal 'opensource'
      expect(newCall.expertId).to.equal '52372c73a9b270020000001c' # Paul
      done()

    v.$('.save').click()

  it "can pay out customer's experts individually as admin", (done) ->
    this.timeout 12000
    {orders, ordersView} = @app

    ###
    wait for orders to sync, get bruce's order
    click payout for each expert
    wait for the order model to sync
    check that everyone is successfully paid out
    ###
    orders.once 'sync', =>
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
