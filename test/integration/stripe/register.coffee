M = require '/scripts/payment/Models'
C = require '/scripts/payment/Collections'
V = require '/scripts/payment/Views'


describe "Stripe: register", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/payment/Router'
    hlpr.setSession 'jk', =>
      done()

  beforeEach ->
    window.location = "#"
    hlpr.cleanSetup @, data.fixtures.stripeRegister

  afterEach ->
    hlpr.cleanTearDown @

  it 'can create a stripe customer', (done) ->
    # initApp session: { authenticated: false }

    rv = @app.registerView

    expect(true).to.be.false
    done()