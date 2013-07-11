hlpr = require '/test/ui-helper'
data = require '/test/data/all'
C = require '/scripts/request/Collections'
f = data.fixtures

storySteps = [
  { appName:'request', usr:'emilLee', frag: '#', fixture: f.request }
  { appName:'dashbaord', usr:'emilLee', frag: '#', fixture: f.dashboard }
  { appName:'review', usr:'emilLee', frag: 'rId', fixture: f.review }
  { appName:'request', usr:'emilLee', frag: '#', fixture: f.request }
  { appName:'review', usr:'anonymous', frag: '#', fixture: f.review }
  { appName:'inbound', usr:'jk', frag: '#', fixture: f.inbound }
  { appName:'review', usr:'richkuo', frag: '#', fixture: f.review }
  { appName:'review', usr:'mattvanhorn', frag: '#', fixture: f.review }
  { appName:'review', usr:'emilLee', frag: '#', fixture: f.review }
  { appName:'inbound', usr:'jk', frag: '#', fixture: f.inbound }
  { appName:'inbound', usr:'jk', frag: '#', fixture: f.inbound }
  { appName:'feedback', usr:'mattvanhorn', frag: '#', fixture: f.feedback }
  { appName:'feedback', usr:'emilLee', frag: '#', fixture: f.feedback }
]
testNum = -1

describe "Story: Emil Lee", ->


  before (done) ->
    @tagsFetch = sinon.stub C.Tags::, 'fetch', -> @set data.tags; @trigger 'sync'
    done()

  beforeEach (done) ->
    testNum++
    hlpr.cleanSetup @, storySteps[testNum].fixture
    window.location = storySteps[testNum].frag
    hlpr.setInitApp @, "/scripts/#{storySteps[testNum].appName}/Router"
    hlpr.setSession storySteps[testNum].usr, =>
      initApp({}, done)

  afterEach ->
    hlpr.cleanTearDown @

  it 'can create request by customer', (done) ->
    {infoFormView,requestFormView} = @app
    @app.company.once 'sync', =>
      infoFormView.elm('name').val 'WPack'
      infoFormView.elm('url').val ''
      infoFormView.elm('about').val 'Looking to build a professional networking website that helps users continuously accomplish their professional goals. For example, mutual introductions through connections.'

      @app.company.once 'sync', =>
        requestFormView.$('.autocomplete').val('ruby').trigger('input')
        $(requestFormView.$('.tt-suggestion')[0]).click()
        requestFormView.elm('brief').val 'I want help firstly with CSS / design. I will ask for assistance with building a "business card" online (using HTML / CSS), and then also a profile. After that, would like help building the front end interaction (JS/AJAX) and back end (rails/postgres).'
        requestFormView.$('#pricingOpensource').click()
        requestFormView.$('#budget1').click()
        requestFormView.elm('availability').val('New York. Available after business hours on weekdays, any time weekends.')

        @app.request.once 'sync', =>
          done()

        requestFormView.$('.save').click()
      infoFormView.$('.save').click()

  # it 'can see request in dashboard by customer', (done) ->


  #   requests
  #   # can see update link
  #   # can see detail link
  #   done()

  # it 'can review request with no experts by customer', (done) ->
  #   done()

  # it 'can update request by customer', (done) ->
  #   done()

  # it 'can review request as anonymous', (done) ->
  #   done()

  # it 'can suggest experts as admin', (done) ->
  #   done()

  # it 'can review request and accept request as expert', (done) ->
  #   done()

  # it 'can review request and decline request as expert', (done) ->
  #   done()

  # it 'can review experts and book hours as customer', (done) ->
  #   done()

  # it 'can schedule call as admin', (done) ->
  #   done()

  # it 'can save call url as admin', (done) ->
  #   # can send how was email?
  #   done()

  # it 'can leave feedback on call as customer', (done) ->
  #   # can send how was email?
  #   done()

  # it 'can leave feedback on call as expert', (done) ->
  #   # can send how was email?
  #   done()