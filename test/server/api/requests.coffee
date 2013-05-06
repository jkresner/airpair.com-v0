require './../test-lib-setup'
require './../test-app-setup'

data =
  users: require './../../data/users'
  requests: require './../../data/requests'


api_skills = require('./../../../lib/api/requests')(app)

cloneReq = (req) ->
  if ! req? then return {}
  r = und.clone req
  delete r._id
  r

describe "REST api requests", ->

  before (done) ->
    @testNum = 0
    createDB done

  beforeEach (done) ->
    @testNum++
    @req = cloneReq data.requests[@testNum]
    #console.log 'test', @testNum, @req.brief
    done()

  it "should get first request", (done) ->
    req = @req
    request(app)
      .post('/api/requests')
      .send( @req )
      .expect(200)
      .end (e, r) ->
        request(app)
          .get('/api/requests')
          .end (err, res) ->
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

  it "should throw error if set to canceled with no detail", (done) ->
    errors = msg: "Update failed", data: { canceledDetail: "Must supply canceled reason" }
    req = cloneReq data.requests[3]
    request(app)
      .post("/api/requests")
      .send(req)
      .end (e, r) ->
        up = und.clone r.body
        up.status = "canceled"
        request(app)
          .put("/api/requests/#{up._id}")
          .send(up)
          .expect(400)
          .end (err, res) ->
            expect( res.body ).to.deep.equal errors
            done()

  it "should add canceled event if status changed to canceled", (done) ->
    req = cloneReq data.requests[3]
    request(app)
      .post("/api/requests")
      .send(req)
      .end (e, r) ->
        up = und.clone r.body
        up.status = "canceled"
        up.canceledDetail = "testing babay"
        request(app)
          .put("/api/requests/#{up._id}")
          .send(up)
          .expect(200)
          .end (err, res) ->
            d = res.body
            expect( d.events.length ).to.equal 2
            expect( d.events[1].name ).to.equal 'canceled'
            expect( d.events[1].by ).to.equal 'Jonathon Kresner'
            done()


  it "should throw error if set to incomplete with no message", (done) ->
    errors = msg: "Update failed", data: { incompleteDetail: "Must supply incomplete reason" }
    req = cloneReq data.requests[3]
    request(app)
      .post("/api/requests")
      .send(req)
      .end (e, r) ->
        up = und.clone r.body
        up.status = "incomplete"
        request(app)
          .put("/api/requests/#{up._id}")
          .send(up)
          .expect(400)
          .end (err, res) ->
            expect( res.body ).to.deep.equal errors
            done()

  it "should add incomplete event if status changed to incomplete", (done) ->
    req = cloneReq data.requests[3]
    request(app)
      .post("/api/requests")
      .send(req)
      .end (e, r) ->
        up = und.clone r.body
        up.status = "incomplete"
        up.incompleteDetail = "testing babay"
        request(app)
          .put("/api/requests/#{up._id}")
          .send(up)
          .expect(200)
          .end (err, res) ->
            d = res.body
            expect( d.events.length ).to.equal 2
            expect( d.events[1].name ).to.equal 'incomplete'
            expect( d.events[1].by ).to.equal 'Jonathon Kresner'
            done()

  # it "should add updated event if details updated by customer", (done) ->

  # it "should add suggested event if new expert suggested by admin", (done) ->

  # it "should add viewed event if viewed by customer", (done) ->

  # it "should add viewed event if viewed by expert", (done) ->

  # it "should add scheduled event call added", (done) ->

  # it "should add completed event if status changed to completed by customer", (done) ->



  after (done) ->
    destroyDB done