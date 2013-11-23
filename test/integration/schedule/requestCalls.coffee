{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app,data,passportMock} = require './../test-app-setup'

require('./../../../lib/api/requests')(app)

# Creates a request and let's you run a test on it
createReq = (reqData, callback) ->
  newReq = _.clone reqData
  delete newReq._id
  http(app).post("/api/requests")
    .send(newReq)
    .expect(200)
    .end (e, r) =>
      if e? then $log 'error', e
      newReq = _.clone r.body
      callback newReq


describe "REST api request calls", ->
  @testNum = 0

  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach -> @testNum++

  it "cannot create call without order credit as customer", (done) ->
    # passportMock.setSession 'admin'
    # createReq data.requests[1], (req) =>
    #   http(app).get('/api/requests')
    #     .end (err, res) =>
    #       d = res.body[0]
    #       expect(d.userId).to.equal data.users[0]._id
    #       expect(d.events.length).to.equal 1
    #       expect(d.company.name).to.equal req.company.name
    #       expect(d.company.contacts.length).to.equal 1
    #       expect(d.status).to.equal 'received'
    #       expect(d.hours).to.equal req.hours
    #       expect(d.brief).to.equal req.brief
    #       expect(d.budget).to.equal req.budget
    #       expect(d.pricing).to.equal req.pricing
    #       expect(d.availability).to.equal req.availability
    #       done()


  it "can create call (with order credit) as customer", (done) ->
    # check experts calendar availability
    # create call object
    # integrate with gCalender
    # send customer an email asking to confirm
    # assert call.status is 'pending'


  it "can confirm call as expert", (done) ->
    # take credit from order
    # send expert email with confirmation


  it "can decline call as expert", (done) ->
    # update call (with reason)
    # assert call.status is 'declined'
    # return the credit to the order object
    # send customer email with wtf were you thinking?
    # send admin email with wtf was the customer thinking?


  it "can get requests by call by times", (done) ->


  it "can get requests by expert (in calls)", (done) ->


  it "can update call with session recording info", (done) ->
    # update call
    # update order (with status of completed hours)
    # send customer email with recording + review link
    # send expert email with recording + review link


  it "can review call as customer", (done) ->
    # check call completed
    # update call


  it "can review call as expert", (done) ->
    # check call completed
    # update call


  it "can update call cms (as customer?)", (done) ->
    # check call completed
    # update call


  it "can get request by call permalink (only when cmsApproved)", (done) ->
    # check call completed
    # cmsApproved is 'complete'
