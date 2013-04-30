{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'

data =
  users: require '/test/data/users'

fixture = "<div id='welcome' class='main'>welcome</div><div id='contactInfo' class='main'>info</div>"

describe "Request: customer signin", ->

  before ->
    $log 'Request: customer signin'
    @SPA = hlpr.set_initSPA '/scripts/request/App'

  beforeEach -> hlpr.clean_setup @, fixture

  afterEach -> hlpr.clean_tear_down @

  it 'not signed in shows step 1', ->
    hlpr.LoadSPA @SPA, { "authenticated": false }
    expect( $('#welcome').is(":visible") ).to.be.true
    expect( $('#contactInfo').is(":visible") ).to.be.false

  it 'signed in w google shows step 2', ->
    hlpr.LoadSPA @SPA
    expect( $('#welcome').is(":visible") ).to.be.false
    expect( $('#contactInfo').is(":visible") ).to.be.true
