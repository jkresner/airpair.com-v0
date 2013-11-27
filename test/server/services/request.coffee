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
    important = [
      'expert updated', 'expert reviewed', 'customer updated',
      'customer expert review' #, 'customer payed' # TODO
    ]
    for ename, i in important
      user = data.users[3]
      request = data.requests[7] # owner is mi
      sendMailMock = sinon.stub svc.mailman, 'sendEmail', (opts, cb) ->
        expect(opts.to).to.equal 'mi@airpair.com'
        sendMailMock.restore()
        if i == important.length - 1
          finished = true
      svc.newEvent request, user, 'expert updated'
    expect(finished).to.equal true

  it "should NOT send an email on un-important newEvent()'s", ->
    sendMailMock = sinon.stub svc.mailman, 'sendEmail', (opts, cb) ->
      throw new Error('sendEmail should not be called!')

    # unimportant events
    for ename in ['create', 'anon view', 'customer view', 'expert view']
      user = data.users[3]
      request = data.requests[7] # owner is mi
      svc.newEvent request, user, ename

    sendMailMock.restore()

  it "should NOT send an email if the request has no owner", ->
    # important new events
    # 'expert updated', 'expert reviewed', 'customer updated', 'customer expert review'

    user = data.users[3]
    request = data.requests[2] # no owner field
    sendMailMock = sinon.stub svc.mailman, 'sendEmail', (opts, cb) ->
      throw new Error('sendEmail should not be called!')

    svc.newEvent request, user, 'expert updated'
    sendMailMock.restore()
