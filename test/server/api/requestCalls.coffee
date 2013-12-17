{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app,data,passportMock} = require './../test-app-setup'

require('./../../../lib/api/requests')(app)

createReq = require('../util/createRequest')(app)

describe "requestCalls REST API", ->
  @testNum = 0

  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach -> @testNum++

  it "should get first request", (done) ->
    passportMock.setSession 'admin'
    createReq data.requests[1], (e, req) =>
      if e then return done e
      http(app).get('/api/requests')
        .end (err, res) =>
          d = res.body[0]
          expect(d.userId).to.equal data.users[0]._id
          expect(d.events.length).to.equal 1
          expect(d.company.name).to.equal req.company.name
          expect(d.company.contacts.length).to.equal 1
          expect(d.status).to.equal 'received'
          expect(d.hours).to.equal req.hours
          expect(d.brief).to.equal req.brief
          expect(d.budget).to.equal req.budget
          expect(d.pricing).to.equal req.pricing
          expect(d.availability).to.equal req.availability
          done()
