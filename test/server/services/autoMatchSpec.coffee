{http,_,sinon,chai,expect,Factory} = require './../test-lib-setup'
{app, data}                                    = require './../test-app-setup'

AutoMatchService = require('./../../../lib/services/autoMatch')

svc = new AutoMatchService

describe "AutoMatchService", ->
  it "should send email to matching experts when activated", (done) ->
    request = data.requests[3]

    mailmanStub = sinon.stub(svc.mailmanService, 'sendAutoNotification')

    Factory.create 'dhh', (dhh) ->
      Factory.create 'aslak', (aslak) ->
        svc.sendExpertNotifications request, ->
          expect(mailmanStub.calledWithMatch(aslak, request)).to.equal true
          done()
