M = require '/scripts/companys/Models'
C = require '/scripts/companys/Collections'
V = require '/scripts/companys/Views'


describe "Settings: paymethods", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/companys/Router'
    done()

  beforeEach ->
    window.location = "#"
    hlpr.cleanSetup @, data.fixtures.companys

  afterEach ->
    hlpr.cleanTearDown @

  it 'can add new shared stripe card paymethod', (done) ->

  it 'can share stripe card with existing user email address', (done) ->
    # updated in payMethod
    # settings of existing user updated with card details

  it 'cannot share stripe card with non-existing user email address', (done) ->
    # returns error

  it 'can share stripe card with existing user with existing stripe card', (done) ->
    # updated in payMethod
    # settings of existing user updated with new card details
    # old card details removed

  it 'can unshare stripe card with existing user', (done) ->
    # updated in payMethod to have sharer
    # settings of existing user updated with new card details
    # updated in payMethod to remove sharer
    # settings of existing user no longer has card details

  it 'can delete card with no sharers', (done) ->

  it 'can delete card with sharers', (done) ->
    # settings of each existing user no longer has card details


## bonus tests (that will not pass with current implementation)

  it 'can share stripe card with existing user with existing shared stripe card', (done) ->
    # returns error "user already using a shared card, unshare old card first"
