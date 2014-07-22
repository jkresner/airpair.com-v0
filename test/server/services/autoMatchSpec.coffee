{http,_,sinon,chai,expect,Factory} = require('./../test-lib-setup')
{app, data} = require './../test-app-setup'

AutoMatchService = require('./../../../lib/services/autoMatch')
svc = new AutoMatchService()

describe "AutoMatchService", ->
  it "should send email to matching experts when activated", (done) ->
    Factory.create 'rails-request', (request) ->
      Factory.create 'dhh', (dhh) ->
        Factory.create 'aslak', (aslak) ->
          mailmanMock = sinon.mock(svc.mailmanService)
          mailmanMock.expects('sendAutoNotification')
            .withArgs(sinon.match.has('email', 'dhh@experts.com'), sinon.match(request)).once()

          svc.sendExpertNotifications request, ->
            mailmanMock.verify()
            done()
