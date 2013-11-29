{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app, data} = require './../test-app-setup'

RequestsService = require('./../../../lib/services/requests')
svc = new RequestsService()

describe "RequestsService", ->
  @testNum = 0

  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach () ->
    @testNum++

  it "should send an email on notifyAdmins", (done) ->
    user = data.users[3]
    request = data.requests[3]
    sendMailMock = sinon.stub svc.mailman, 'sendEmailToAdmins', ->
    callback = (e) ->
      if e then return done e
      expect(sendMailMock.calledWith(sinon.match.has("subject", "New airpair request: Roger Toor 90$"))).to.equal true
      expect(sendMailMock.calledOnce).to.equal true
      sendMailMock.restore()
      done()

    svc.create(user, request, callback)

  it "should send an email on important newEvent()'s", ->
    finished = false
    importantEvents = [
      'expert reviewed', 'customer updated', 'customer expert review'
      #, 'customer payed' # TODO
    ]
    for ename, i in importantEvents
      request = data.requests[7] # owner is mi
      request.user = data.users[3]
      sendMailMock = sinon.stub svc.mailman, 'sendEmail', (opts, cb) ->
        expect(opts.to).to.equal 'mi@airpair.com'
        sendMailMock.restore()
        if i == importantEvents.length - 1
          finished = true
      svc.newEvent request, ename
    expect(finished).to.equal true

  it "should NOT send an email on un-important newEvent()'s", ->
    sendMailMock = sinon.stub svc.mailman, 'sendEmail', (opts, cb) ->
      throw new Error('sendEmail should not be called!')

    unimportantEvents = ['create', 'anon view', 'customer view', 'expert view',
      'expert updated']
    for ename in unimportantEvents
      request = data.requests[7]
      request.user = data.users[3]
      svc.newEvent request, ename

    sendMailMock.restore()

  it "should NOT send an email if the request has no owner", ->
    request = data.requests[2] # no owner field
    request.user = data.users[3]
    sendMailMock = sinon.stub svc.mailman, 'sendEmail', (opts, cb) ->
      throw new Error('sendEmail should not be called!')

    svc.newEvent request, 'expert reviewed'
    sendMailMock.restore()
