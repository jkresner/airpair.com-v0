M = require '/scripts/review/Models'
C = require '/scripts/review/Collections'
V = require '/scripts/review/Views'


createStripeCustomerDetails = (callback) ->
  hlpr.setInitApp @, '/scripts/payment/Router'
  hlpr.cleanSetup @, data.fixtures.stripeReg
  initApp customerId: null, session: data.users[0], pk: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'

  rv = @app.registerView

  rv.model.once 'sync', =>
    rv.$('[data-stripe=number]').val("4242 4242 4242 4242")
    rv.$('[data-stripe=cvc]').val("424")
    rv.$('[data-stripe=exp-month]').val("10")
    rv.$('[data-stripe=exp-year]').val("14")

    rv.$('button').click()

    rv.model.once 'sync', =>
      $log 'rv.sync', rv.model.attributes
      pMethods = rv.model.get('paymentMethods')

      $log 'rv.model', rv.model.attributes.stripeCreate
      hlpr.cleanTearDown @
      callback()


describe "Review: book with stripe", ->

  before (done) ->
    createStripeCustomerDetails =>
      hlpr.setInitApp @, '/scripts/review/Router'
      hlpr.setSession 'emilLee', =>
        $.post('/api/requests',data.requests[8]).done (r) =>
          $.get("/api/requests/#{r._id}").done (r) =>
            @r = r
            done()

  beforeEach ->
    window.location = "#"+@r._id
    hlpr.cleanSetup @, data.fixtures.review
    initApp session: data.users[6], request: @r

  afterEach ->
    hlpr.cleanTearDown @

  it "can book expert hours as customer with Stripe", (done) ->
    rv = @app.requestView
    bv = @app.bookView
    req = rv.request

    $log 'router.app.settings.attributes', router.app.settings.attributes
    router.navTo "#book/stripe"

    expect( bv.$('#bookableExperts .bookableExpert').length ).to.equal 1
    $kuo = $(bv.$('#bookableExperts .bookableExpert')[0])
    expect( $kuo.find('.username').html() ).to.equal '@richkuo'
    $kuo.find('[name=qty]').val('2').trigger('change')
    $kuo.find('[name=type]').val('private').trigger('change')

    payWith = bv.model.get('payWith')
    expect( payWith.type ).to.equal 'stripe'

    bv.model.once 'sync', =>
      m = bv.model
      # $log 'synced'
      expect( m.get('requestId') ).to.equal req.id
      expect( m.get('total') ).to.equal 160
      expect( m.get('lineItems').length ).to.equal 1
      done()

    bv.$('.pay').click()