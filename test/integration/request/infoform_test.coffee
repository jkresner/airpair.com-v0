hlpr = require '/test/ui-helper'
data = require '/test/data/all'

pageData = { session: data.users[0] }

describe "Request: infoForm", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/request/Router'
    hlpr.setSession 'admin', done # note this test is expecting admin user
  beforeEach -> hlpr.cleanSetup @, data.fixtures.request
  afterEach -> hlpr.cleanTearDown @

  it 'missing full name & email fires validation', (done) ->
    initApp pageData
    v = @app.infoFormView
    checkValidationErrors = ->
      v.$("#contactName").val('')
      v.$("#contactEmail").val('')
      v.$(".save").click()
      expect( hlpr.showsError(v.$("#contactName")) ).to.be.true
      v.$("#contactName").val('Jonny Kong')
      v.$(".save").click()
      expect( hlpr.showsError(v.$("#contactName")) ).to.be.false
      expect( hlpr.showsError(v.$("#contactEmail")) ).to.be.true
      v.$("#contactEmail").val('test@jk.com')
      v.$(".save").click()
      expect( hlpr.showsError(v.$("#contactName")) ).to.be.false
      expect( hlpr.showsError(v.$("#contactEmail")) ).to.be.false

      @app.company.once 'sync', => done()

    @app.company.once 'sync', checkValidationErrors, @

  it 'company name & less than 100 words on about company fires validation', (done) ->
    initApp pageData
    v = @app.infoFormView

    checkValidationErrors = ->
      v.$("#companyName").val('')
      v.$("#companyAbout").val('')
      v.$(".save").click()
      expect( hlpr.showsError(v.$("#contactName")) ).to.be.false
      expect( hlpr.showsError(v.$("#contactEmail")) ).to.be.false
      expect( hlpr.showsError(v.$("#companyName")) ).to.be.true
      expect( hlpr.showsError(v.$("#companyAbout")) ).to.be.true
      v.$("#companyName").val('test inc.')
      v.$(".save").click()
      expect( hlpr.showsError(v.$("#companyName")) ).to.be.false
      expect( hlpr.showsError(v.$("#companyAbout")) ).to.be.true
      v.$("#companyAbout").val('test inc.')
      v.$(".save").click()
      expect( hlpr.showsError(v.$("#companyAbout")) ).to.be.true
      v.$("#companyAbout").val('airpair is fundamentally about sharing knowledge with the community. We use your session recording for educational purposes. Allowing the session recording to be public also helps our experts build a reputation for themselves.')
      v.$(".save").click()
      expect( hlpr.showsError(v.$("#companyAbout")) ).to.be.false

      @app.company.once 'sync', => done()

    @app.company.once 'sync', checkValidationErrors, @