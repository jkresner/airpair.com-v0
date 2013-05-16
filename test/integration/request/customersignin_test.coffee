{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'

data =
  users: require '/test/data/users'

fixture = "<div id='welcome' class='route'>welcome</div>
           <div id='info' class='route'>info</div>"
pageData = {}

describe "Request: customer signin", ->

  before -> hlpr.set_initApp '/scripts/request/Router'
  afterEach -> hlpr.clean_tear_down @
  beforeEach -> hlpr.clean_setup @, fixture

  it 'not signed in shows step 1', ->
    initApp session: { "authenticated": false }
    expect( $('#welcome').is(":visible") ).to.be.true
    expect( $('#info').is(":visible") ).to.be.false

  it 'signed in w google shows step 2', ->
    initApp session: data.users[4]
    expect( $('#welcome').is(":visible") ).to.be.false
    expect( $('#info').is(":visible") ).to.be.true