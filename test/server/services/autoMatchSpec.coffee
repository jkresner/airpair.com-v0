{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app, data}                                    = require './../test-app-setup'

AutoMatchService = require('./../../../lib/services/autoMatch')
svc = new AutoMatchService(data.users[3])

describe "AutoMatchService", ->
  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach () ->

  it "should send email to matching experts when activated", (done) ->
    user = data.users[3]
    request = data.requests[3]

    sendMailMock = sinon.stub svc.mailman, 'sendAutoNotification', ->

    callback = (e) ->
      if e then return done e
      expect(sendMailMock.calledWith(sinon.match.has("subject", "New request: Roger Toor 90$"))).to.equal true
      expect(sendMailMock.calledOnce).to.equal true
      sendMailMock.restore()
      done()

    svc.sendAutoNotifications request, callback
