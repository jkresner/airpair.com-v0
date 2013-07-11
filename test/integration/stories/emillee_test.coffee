hlpr = require '/test/ui-helper'
data = require '/test/data/all'
f = data.fixtures

storySteps = [
  { appName:'request', frag: '#', usr:'emilLee', fixture: fixtures.request }
  { appName:'dashbaord', frag: '#', usr:'emilLee', fixture: fixtures.dashboard }
  { appName:'review', frag: 'rId', usr:'emilLee', fixture: fixtures.review }
  { appName:'request', usr:'emilLee', fixture: fixtures.request }
  { appName:'review', frag: 'rId', usr:'anonymous', fixture: fixtures.review }
  { appName:'inbound', usr:'jk', fixture: fixtures.inbound }
  { appName:'review', usr:'richkuo', fixture: fixtures.review }
  { appName:'review', usr:'mattvanhorn', fixture: fixtures.review }
  { appName:'review', usr:'emilLee', fixture: fixtures.review }
  { appName:'inbound', usr:'jk', fixture: fixtures.inbound }
  { appName:'inbound', usr:'jk', fixture: fixtures.inbound }
  { appName:'feedback', usr:'mattvanhorn', fixture: fixtures.feedback }
  { appName:'feedback', usr:'emilLee', fixture: fixtures.feedback }
]

describe "Story: Emil Lee", ->

  @testNum = -1

  before (done) ->

  beforeEach (done) ->
    @testNum++
    hlpr.cleanSetup @, fixture
    window.location = storySteps[@testNum].frag
    hlpr.setInitApp "/scripts/#{storySteps[@testNum]}/Router"
    hlpr.setSession storySteps[@testNum].usr, =>
      done()

  afterEach ->
    hlpr.cleanTearDown @

  it 'can create request by customer', (done) ->
    # initApp session: { authenticated: false }
    # @router = window.router
    done()

  it 'can see request in dashboard by customer', (done) ->
    # can see update link
    # can see detail link
    done()

  it 'can review request with no experts by customer', (done) ->
    done()

  it 'can update request by customer', (done) ->
    done()

  it 'can review request as anonymous', (done) ->
    done()

  it 'can suggest experts as admin', (done) ->
    done()

  it 'can review request and accept request as expert', (done) ->
    done()

  it 'can review request and decline request as expert', (done) ->
    done()

  it 'can review experts and book hours as customer', (done) ->
    done()

  it 'can schedule call as admin', (done) ->
    done()

  it 'can save call url as admin', (done) ->
    # can send how was email?
    done()

  it 'can leave feedback on call as customer', (done) ->
    # can send how was email?
    done()

  it 'can leave feedback on call as expert', (done) ->
    # can send how was email?
    done()