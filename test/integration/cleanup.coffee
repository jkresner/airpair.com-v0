{expect,dbConnect,dbDestroy} = require('./../server/test-lib-setup')

describe "Integration suite cleanup", ->

  before dbConnect
  after (done) ->
    this.timeout 5000
    dbDestroy done

  it 'cleaned-up & destroyed test database', ->
    expect(true).to.be.true
