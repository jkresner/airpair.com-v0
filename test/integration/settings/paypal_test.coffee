M = require '/scripts/settings/Models'
C = require '/scripts/settings/Collections'
V = require '/scripts/settings/Views'


describe "Settings: paypal", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/settings/Router'
    done()

  beforeEach ->
    window.location = "#"
    hlpr.cleanSetup @, data.fixtures.settings

  afterEach ->
    hlpr.cleanTearDown @

  it 'can add paypal settings to empty settings object', (done) ->
    hlpr.setSession 'emilLee', =>
      initApp settings: {}, session: data.users[6]

      psv = @app.paymentSettingsView

      expect(psv.elm('paypalEmail').val()).to.equal ''
      expect(psv.model.get('paymentMethods').length).to.equal 0

      psv.elm('paypalEmail').val 'emlee@paypal.com'
    
      psv.model.once 'sync', =>

        paymentMethods = psv.model.get('paymentMethods')
        expect(paymentMethods.length).to.equal 1
        expect(paymentMethods[0].type).to.equal 'paypal'
        expect(paymentMethods[0].info.email).to.equal 'emlee@paypal.com'

        done()

      psv.$('.save').click()

  # it 'can add paypal settings to existing settings object with strip settings', (done) ->
    # richkuo

