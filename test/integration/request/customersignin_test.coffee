pageData = {}

describe "Request: customer signin", ->

  before -> hlpr.setInitApp @, '/scripts/request/Router'
  afterEach -> hlpr.cleanTearDown @
  beforeEach -> hlpr.cleanSetup @, data.fixtures.request

  # TODO: JK comment back in and make it work
  # it 'not signed in shows step 1', ->
  #   initApp session: { authenticated: false }
  #   expect( $('#welcome').is(":visible") ).to.be.true
  #   expect( $('#info').is(":visible") ).to.be.false

  # it 'signed in w google shows step 2', ->
  #   initApp session: data.users[4]
  #   expect( $('#welcome').is(":visible") ).to.be.false
  #   expect( $('#info').is(":visible") ).to.be.true
