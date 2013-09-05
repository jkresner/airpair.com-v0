{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app, data} = require './../test-app-setup'

RequestsService = require('./../../../lib/services/requests')
svc = new RequestsService()

describe "RequestsService", ->
  @testNum = 0

  before (done) ->
    dbConnect done
  after (done) ->
    dbDestroy done
  beforeEach () ->
    @testNum++

  it "should send an email on notifyAdmins", (done) ->
    user = data.users[3]
    request = data.requests[3]
    sendMailMock = sinon.stub svc.mailman, 'sendEmailToAdmins', ->
    callback = ->
      expect(sendMailMock.calledWith(sinon.match.has("subject", "New airpair request: Roger Toor 90$"))).to.equal true
      expect(sendMailMock.calledOnce).to.equal true
      done()
      sendMailMock.restore()

    svc.create(user, request, callback)

