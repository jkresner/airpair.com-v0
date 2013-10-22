M = require '/scripts/settings/Models'
C = require '/scripts/settings/Collections'
V = require '/scripts/settings/Views'


describe "Settings: stripe register", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/settings/Router'
    hlpr.setSession 'jk', =>
    done()

  beforeEach ->
    window.location = "#"
    hlpr.cleanSetup @, data.fixtures.settings

  afterEach ->
    hlpr.cleanTearDown @

  it 'can create a stripe customer with new settings object', (done) ->
    
    initApp settings: {}, session: data.users[0], stripePK: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'

    psv = @app.paymentSettingsView
    rv = @app.stripeRegisterView

    expect( psv.$('.setup').html() ).to.equal 'Setup billing info'
    expect( rv.$el.is(':visible') ).to.equal false
    psv.$('.setup').click()
    router.navTo psv.$('.setup').attr('href') #not sure why had to do this        
    expect( rv.$el.is(':visible') ).to.equal true

    rv.$('[data-stripe=number]').val("4242 4242 4242 4242")
    rv.$('[data-stripe=cvc]').val("424")
    rv.$('[data-stripe=exp-month]').val("10")
    rv.$('[data-stripe=exp-year]').val("14")

    rv.model.once 'sync', =>
      $log 'rv.sync', rv.model.attributes
      pMethods = rv.model.get('paymentMethods')
      expect(pMethods.length).to.equal 1
      expect(pMethods[0].type).to.equal 'stripe'

      # $log 'rv.model', rv.model.attributes.stripeCreate
      expect(rv.model.has('stripeCreate')).to.equal false
      done()

    rv.$('button').click()