M = require '/scripts/payment/Models'
C = require '/scripts/payment/Collections'
V = require '/scripts/payment/Views'


describe "Settings: stripe register", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/payment/Router'

    done()

  beforeEach ->
    window.location = "#"
    hlpr.cleanSetup @, data.fixtures.stripeReg
    $log 'data.fixtures.stripeRegister', data.fixtures.stripeReg

  afterEach ->
    hlpr.cleanTearDown @

  it 'can create a stripe customer with new settings object', (done) ->
    hlpr.setSession 'jk', =>
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
          expect(pMethods.length).to.equal 1
          expect(pMethods[0].type).to.equal 'stripe'

          $log 'rv.model', rv.model.attributes.stripeCreate
          expect(rv.model.has('stripeCreate')).to.equal false
          done()