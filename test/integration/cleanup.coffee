{expect,dbConnect,dbDestroy} = require('./../server/test-lib-setup')

describe "Server-side suite cleanup", ->

  before (done) -> dbConnect done
  after (done) -> dbDestroy done

  it 'cleaned-up & destroyed test database', ->
    expect(true).to.be.true