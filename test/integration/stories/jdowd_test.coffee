Tags = require('/scripts/request/Collections').Tags
calcExpertCredit = require '/scripts/shared/mix/calcExpertCredit'
f                = data.fixtures

request = _.clone(data.requests[13]) # John Dowd

storySteps = [
  { app:'settings/Router', usr:'jdowd', frag: '#', fixture: f.settings, pageData: { stripePK: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl' } }
  { app:'request/Router', usr:'jdowd', frag: '#', fixture: f.request, pageData: {} }
  { app:'inbound/Router', usr:'admin', frag: '#', fixture: f.inbound, pageData: { experts: data.experts, tags: data.tags } }
  { app:'review/Router', usr:'jdowd', frag: '#rId', fixture: f.review, pageData: {} }
  # { app:'calls/RouterSchedule', usr: 'admin', frag: '#/schedule/rId', fixture: f.callSchedule, pageData: { request: request, isAdmin: true } }
  # { app:'calls/RouterSchedule', usr: 'admin', frag: '#/schedule/rId', fixture: f.callSchedule, pageData: { request: request, isAdmin: true } }
  # { app:'calls/RouterSchedule', usr: 'admin', frag: '#/schedule/rId', fixture: f.callSchedule, pageData: { request: request, isAdmin: true } }
  # { app:'calls/RouterSchedule', usr: 'admin', frag: '#/schedule/rId', fixture: f.callSchedule, pageData: { request: request, isAdmin: true } }
  # # note: these two have a callId set as @rId
  # { app:'calls/RouterEdit', usr: 'admin', frag: '#', fixture: f.callEdit, pageData: { request: request } }
  # { app:'calls/RouterEdit', usr: 'admin', frag: '#', fixture: f.callEdit, pageData: { request: request } }
  # john does some customer call scheduling
  { app:'calls/RouterSchedule', usr: 'jdowd', frag: '#/schedule/rId', fixture: f.callSchedule, pageData: { request: request, isAdmin: false } }
  { app:'calls/RouterCalls', usr: 'rbigg', frag: '#', fixture: f.calls, pageData: {} }
  { app:'calls/RouterSchedule', usr: 'jdowd', frag: '#/schedule/rId', fixture: f.callSchedule, pageData: { request: request, isAdmin: false } }
  { app:'calls/RouterCalls', usr: 'rbigg', frag: '#', fixture: f.calls, pageData: {  } }
]

testNum = -1
dateFormat = "DD MMM YYYY"
timeFormat = 'HH:mm'

# This story is meant to test the call editing functionality; for this reason,
# many of the other "tests" don't test much (they are already tested by
# bchristie's story)
describe "Stories: John Dowd", ->

  before (done) ->
    @tagsFetch = sinon.stub Tags::, 'fetch', -> @set data.tags; @trigger 'sync'
    done()

  after -> @tagsFetch.restore()

  beforeEach (done) ->
    testNum++
    hlpr.cleanSetup @, storySteps[testNum].fixture
    window.location = storySteps[testNum].frag.replace 'rId', @rId
    hlpr.setInitApp @, "/scripts/#{storySteps[testNum].app}"
    console.log "===== #{storySteps[testNum].usr}"
    hlpr.setSession storySteps[testNum].usr, (__, session) =>
      console.log 'app', storySteps[testNum].app #, storySteps[testNum].pageData
      # console.log 'session', session
      initApp(storySteps[testNum].pageData, done)

  afterEach ->
    hlpr.cleanTearDown @

  it 'can create stripe settings', (done) ->
    @timeout 10000
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

      rv.$('button').click()
      rv.model.once 'sync', =>
        pMethods = rv.model.get('paymentMethods')
        expect(pMethods.length).to.equal 1
        expect(pMethods[0].type).to.equal 'stripe'
        done()

  it 'can create request by customer', (done) ->
    {infoFormView,requestFormView} = @app
    @app.company.once 'sync', =>
      props = ['name', 'url', 'about']
      @app.company.set _.pick request.company, props

      @app.company.save()
      @app.company.once 'sync', =>
        props = ['tags', 'brief', 'availability', 'budget', 'pricing', 'hours'
        'company']
        @app.request.set _.pick request, props

        @app.request.save()
        @app.request.once 'sync', =>
          @rId = @app.request.id
          request._id = @rId
          r = @app.request.toJSON()
          expect(r.company.name).to.equal request.company.name
          expect(r.pricing).to.equal request.pricing

          # we need the ID for the call stuff
          storySteps[4].pageData.request._id = @rId
          done()

  it 'can suggest experts as admin', (done) ->
    @timeout 10000
    rv = @app.requestView

    @app.requests.once 'sync', =>
      router.navTo "##{@rId}"
      @app.selected.once 'sync', saveSuggestions

    saveSuggestions = =>
      changes = { suggested: request.suggested, owner: request.owner }
      @app.selected.save changes, success: (model) =>
        expect( @app.selected.get('suggested').length ).to.equal 3
        expect( @app.selected.get('owner') ).to.equal 'jk'
        done()

  it 'can review experts and book hours as customer with stripe', (done) ->
    {settings,requestView} = @app
    requestModel = @app.request
    synced = 0
    settings.once 'sync', => synced++; if synced == 2 then test()
    requestModel.once 'sync', => synced++; if synced == 2 then test()

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
      $ryanB = $($bookableExperts[0])
      $ivanS = $($bookableExperts[2])

      $ryanB.find('[name=qty]').val('10').trigger 'change'
      expect( bv.$('#pay').is(':visible') ).to.equal true
      expect( bv.$('.payStripe').is(':visible') ).to.equal true

      bv.model.once 'sync', (model) =>
        expect( model.get('total') ).to.equal 2600
        done()
      bv.$('.payStripe').click()

  callId = null
  scheduleCall = (app, call, duration, done) =>
    {requestCall, orders, callScheduleView} = app
    v = callScheduleView
    preCredit = null
    orders.once 'sync', =>
      preCredit = calcExpertCredit orders.toJSON(), call.expertId

      delete call._id
      call.date = moment(call.datetime).format(dateFormat)
      call.time = moment(call.datetime).format(timeFormat)
      requestCall.set call
      requestCall.save()
      v.renderSuccess = -> # disable the redirect after save
      v.model.once 'sync', onSync
    onSync = (model, resp) =>
      console.log 'saved'
      expect(v.model.get('errors')).to.equal undefined
      # the model is now a full request
      newCall = _.last v.model.toJSON().calls
      callId = newCall._id
      if newCall.timezone == 'America/Los_Angeles'
        expect(newCall.datetime).to.equal call.datetime
      expect(newCall.duration).to.equal duration
      expect(newCall.type).to.equal call.type
      expect(newCall.expertId).to.equal '52854908dc3dd1020000001c' # Ryan

      orders.fetch success: (-> assertCredit newCall), reset: true
    assertCredit = (newCall) =>
      postCredit = calcExpertCredit orders.toJSON(), call.expertId
      expect(postCredit.balance).to.equal preCredit.balance - duration
      expect(postCredit.redeemed).to.equal preCredit.redeemed + duration
      done(null, newCall)
  ###
  it 'can schedule first 1 hour call as admin', (done) ->
    @timeout 20000
    call = request.calls[0]
    scheduleCall(@app, call, 1, done)

  it 'can schedule second 1 hour call as admin', (done) ->
    @timeout 20000
    call = request.calls[1]
    scheduleCall(@app, call, 1, done)

  it 'can schedule third 1 hour call as admin', (done) ->
    @timeout 20000
    call = request.calls[2]
    scheduleCall(@app, call, 1, done)

  it 'can schedule fourth and last 2 hour call as admin', (done) ->
    @timeout 20000
    call = request.calls[3]
    scheduleCall(@app, call, 2, done)

  it 'can edit fourth call down to 1 hour as admin', (done) ->
    @timeout 20000
    v = @app.callEditView
    v.renderSuccess = -> # disable the redirect after save
    call = request.calls[3] # original calls
    $.ajax("/_viewdata/callEdit/#{callId}")
    .fail (__, ___, errorThrown) =>
      done(errorThrown)
    .done (data) =>
      @app.request.set data.request, reset: true
      @app.orders.set data.orders, reset: true
      test()
    test = =>
      router.navTo "#/edit/#{callId}"
      setTimeout onEditPage, 100
    onEditPage = =>
      # assert all the fields match what is currently in the call
      date = moment(call.datetime).format(dateFormat)
      time = moment(call.datetime).format(timeFormat)
      expect(v.elm('duration').val()).to.equal '2'
      expect(v.elm('date').val()).to.equal date
      expect(v.elm('time').val()).to.equal time
      # expect(v.elm('type').val()).to.equal call.type

      # change to duration 1
      v.elm('duration').val('1')
      # change the date to now
      @now = new Date()
      v.elm('date').val(moment(@now).format(dateFormat))
      v.elm('time').val(moment(@now).format(timeFormat))

      v.$('.save').click()
      @app.requestCall.once 'sync', onSync
    onSync = =>
      saved = @app.requestCall.toJSON()
      expect(saved.duration).to.equal 1
      # TODO figure out why this doesnt pass
      # expect(saved.datetime).to.equal @now.toJSON()
      done()

  it 'can edit fourth call back to 2 hours as admin', (done) ->
    @timeout 20000
    v = @app.callEditView
    v.renderSuccess = -> # disable the redirect after save
    $.ajax("/_viewdata/callEdit/#{callId}")
    .fail (__, ___, errorThrown) =>
      done(errorThrown)
    .done (data) =>
      @app.request.set data.request, reset: true
      @app.orders.set data.orders, reset: true
      test()
    test = =>
      router.navTo "#/edit/#{callId}"
      setTimeout onEditPage, 100
    onEditPage = =>
      expect(v.elm('duration').val()).to.equal '1'

      v.elm('duration').val('2')

      v.$('.save').click()
      @app.requestCall.once 'sync', onSync
    onSync = =>
      saved = @app.requestCall.toJSON()
      expect(saved.duration).to.equal 2
      done()
  ###
  credit = null
  it 'can customer-schedule first 1 hour call', (done) ->
    @timeout 20000
    call = _.cloneDeep request.calls[4]
    call.timezone = 'Europe/Berlin'
    scheduleCall @app, call, 1, (err, newCall) =>
      expect(newCall.gcal).to.equal undefined
      console.log call.datetime, 'vs', newCall.datetime
      sameTime = new Date(call.datetime).getTime() == new Date(newCall.datetime).getTime()
      expect(sameTime).to.equal false
      done()

    @app.orders.once 'sync', =>
      credit = calcExpertCredit @app.orders.toJSON(), call.expertId

  it 'expert Ryan can decline first call', (done) ->
    @timeout 20000
    v = @app.callsView

    synced = 0
    # save ryan's expert profile
    $.post('/api/experts', data.experts[10]).done(-> fetch('d')).fail(-> fetch('f'))
    fetch = (data) =>
      # cant see his calls if he doesnt have an expert profile
      @app.calls.fetch( success: (-> setTimeout hitPage, 100), reset: true )

    declinedCallId = null
    hitPage = =>
      # console.log 'hitpage', @app.calls.toJSON()
      # the correct call is in there
      expect(!!_.find @app.calls.toJSON(), (c) -> c._id == callId).to.equal true

      # now trigger a get request on the decline url.
      decline = $(v.$(".schedule[data-id='#{callId}']")[1])
      declineUrl = decline.attr('href')
      declinedCallId = decline.data('id')
      expect(!!declinedCallId).to.equal true
      expect(!!declineUrl).to.equal true
      $.get(declineUrl).done(fetchCalls).fail(fetchCalls)
    fetchCalls = => @app.calls.fetch(success: assertDeclined, reset: true )
    assertDeclined = (calls) =>
      updated = _.find calls.toJSON(), (c) -> c._id == declinedCallId
      expect(updated.status).to.equal 'declined'
      done()

  it 'can customer-schedule second 1 hour call', (done) ->
    @timeout 20000
    call = _.cloneDeep request.calls[4]
    call.duration = 5

    @app.orders.once 'sync', =>
      # the declined call should not count against their balance.
      updatedCredit = calcExpertCredit @app.orders.toJSON(), call.expertId
      expect(updatedCredit.balance).to.equal credit.balance
      expect(updatedCredit.redeemed).to.equal credit.redeemed

    scheduleCall @app, call, 5, (err, newCall) =>
      expect(newCall.gcal).to.equal undefined
      done()

  it 'expert ryan can accept second call', (done) ->
    @timeout 20000
    v = @app.callsView
    confirmCallId = null
    @app.calls.once 'reset', =>
      # the correct call is in there
      expect(!!_.find @app.calls.toJSON(), (c) -> c._id == callId).to.equal true

      # now trigger a get request on the confirm url.
      confirm = $(v.$(".schedule[data-id='#{callId}']")[0])
      confirmUrl = confirm.attr('href')
      confirmCallId = confirm.data('id')
      expect(!!confirmCallId).to.equal true
      expect(!!confirmUrl).to.equal true
      $.get(confirmUrl).done(fetchCalls).fail(fetchCalls)
    fetchCalls = =>
      @app.calls.fetch(success: assertConfirm, reset: true )
    assertConfirm = (calls) =>
      updated = _.find calls.toJSON(), (c) -> c._id == confirmCallId
      expect(updated.status).to.equal 'confirmed'
      done()
