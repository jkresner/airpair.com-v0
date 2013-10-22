M = require '/scripts/review/Models'
C = require '/scripts/review/Collections'
V = require '/scripts/review/Views'
SV = require '/scripts/settings/Views'


createStripeCustomerDetails = (callback) ->
  hlpr.cleanSetup @, "<div id='stripeRegister'></div>"
  rv = new SV.StripeRegisterView model: new M.Settings(), session: new M.User(data.users[11])
  Stripe.setPublishableKey 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'
  rv.model.on 'sync', =>
    rv.$('[data-stripe=number]').val("4242 4242 4242 4242")
    rv.$('[data-stripe=cvc]').val("424")
    rv.$('[data-stripe=exp-month]').val("10")
    rv.$('[data-stripe=exp-year]').val("14")
    rv.$('button').click()
    rv.successAction = =>
      $log 'rv.model.id', rv.model.id
      hlpr.cleanTearDown @
      callback()
  rv.model.fetch()

describe "Review: book with stripe", ->

  before (done) ->
    @timeout(0)
    hlpr.setInitApp @, '/scripts/review/Router'
    hlpr.setSession 'janPetrovic', =>
      createStripeCustomerDetails =>
        $.post('/api/requests',data.requests[8]).done (r) =>
          $.get("/api/requests/#{r._id}").done (rr) => # so we get expert pricing form the service
            @r = rr
            done()

  beforeEach ->
    window.location = "#"+@r._id
    hlpr.cleanSetup @, data.fixtures.review
    initApp session: data.users[11], request: @r

  afterEach ->
    hlpr.cleanTearDown @

  it "can book expert hours as customer with Stripe", (done) ->
    rv = @app.requestView
    bv = @app.bookView
    req = rv.request
  
    rv.settings.once 'sync', =>

      router.navTo "#stripe/book"

      expect( bv.$('#bookableExperts .bookableExpert').length ).to.equal 1
      $kuo = $(bv.$('#bookableExperts .bookableExpert')[0])
      expect( $kuo.find('.username').html() ).to.equal '@richkuo'
      $kuo.find('[name=qty]').val('2').trigger('change')
      $kuo.find('[name=type]').val('private').trigger('change')

      payWith = bv.model.get('paymentMethod')
      expect( payWith.type ).to.equal 'stripe'

      bv.model.once 'sync', =>
        m = bv.model
        # $log 'synced'
        expect( m.get('requestId') ).to.equal req.id
        expect( m.get('total') ).to.equal 160
        expect( m.get('lineItems').length ).to.equal 1
        expect( m.get('paymentStatus') ).to.equal 'received'
        done()

      bv.$('.pay').click()