M = require '/scripts/payment/Models'
C = require '/scripts/payment/Collections'
V = require '/scripts/payment/Views'


describe "Payment: stripe register", ->

  before (done) ->
    $log 'in before yeah'
    hlpr.setInitApp @, '/scripts/payment/Router'
    hlpr.setSession 'jk', =>
      done()

  beforeEach ->
    window.location = "#"
    hlpr.cleanSetup @, data.fixtures.stripeRegister

  afterEach ->
    hlpr.cleanTearDown @

  it 'can create a stripe customer', (done) ->
    initApp customerId: null, session: data.users[0], pk: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'

    rv = @app.registerView

    expect(true).to.be.false

    rv.model.once 'sync', =>
      rv.$('[data-stripe=number]').val("4242 4242 4242 4242")
      rv.$('[data-stripe=cvc]').val("424")
      rv.$('[data-stripe=exp-month]').val("10")
      rv.$('[data-stripe=exp-year]').val("14")

      rv$('button').click()

      rv.model.once 'sync', =>

        $log 'saving yeah'
        done()