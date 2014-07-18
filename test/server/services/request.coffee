{http,_,sinon,chai,expect} = require './../test-lib-setup'
{app, data} = require './../test-app-setup'

RequestsService = require('./../../../lib/services/requests')
svc = new RequestsService(data.users[3])

describe "RequestsService", ->

  it "should send an email on notifyAdmins", (done) ->
    user = data.users[3]
    request = data.requests[3]
    delete request._id

    sendMailMock = sinon.stub svc.mailman, 'sendEmailToAdmins', ->

    callback = (e) ->
      if e then return done e
      expect(sendMailMock.calledWith(sinon.match.has("subject", "New request: Roger Toor 90$"))).to.equal true
      expect(sendMailMock.calledOnce).to.equal true
      sendMailMock.restore()
      done()

    svc.create request, callback
