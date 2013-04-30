{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'

data =
  users: require '/test/data/users'

fixture = "<div id='welcome' class='main'>welcome</div><div id='contactInfo' class='main'>info</div>"

describe "Request: contactInfo", ->

  before ->
    $log 'Request: contactInfo form'
    @SPA = hlpr.set_initSPA '/scripts/request/App'

  beforeEach -> hlpr.clean_setup @, fixture

  afterEach -> hlpr.clean_tear_down @

  it 'missing full name & email fires validation', (done) ->
    hlpr.LoadSPA @SPA
    v = router.page.contactInfoView

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
      done()

    router.page.company.once 'sync', checkValidationErrors, @

  it 'company name & less than 100 words on about company fires validation', (done) ->
    hlpr.LoadSPA @SPA
    view = router.page.contactInfoView

    checkValidationErrors = ->
      view.$("#companyName").val('')
      view.$("#companyAbout").val('')
      view.$(".save").click()
      expect( true ).to.be.true
      expect( hlpr.showsError(view.$("#contactName")) ).to.be.false
      expect( hlpr.showsError(view.$("#contactEmail")) ).to.be.false
      expect( hlpr.showsError(view.$("#companyName")) ).to.be.true
      expect( hlpr.showsError(view.$("#companyAbout")) ).to.be.true
      view.$("#companyName").val('test inc.')
      view.$(".save").click()
      expect( hlpr.showsError(view.$("#companyName")) ).to.be.false
      expect( hlpr.showsError(view.$("#companyAbout")) ).to.be.true
      view.$("#companyAbout").val('test inc.')
      view.$(".save").click()
      expect( hlpr.showsError(view.$("#companyAbout")) ).to.be.true
      view.$("#companyAbout").val('airpair is fundamentally about sharing knowledge with the community. We use your session recording for educational purposes. Allowing the session recording to be public also helps our experts build a reputation for themselves.')
      view.$(".save").click()
      expect( hlpr.showsError(view.$("#companyAbout")) ).to.be.false
      done()

    router.page.company.once 'sync', checkValidationErrors, @