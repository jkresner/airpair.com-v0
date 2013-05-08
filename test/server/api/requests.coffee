require './../test-lib-setup'
require './../test-app-setup'

data =
  users: require './../../data/users'
  requests: require './../../data/requests'


api_skills = require('./../../../lib/api/requests')(app)

createReq = (reqData, callback) ->
  newReq = und.clone reqData
  delete newReq._id
  request(app)
    .post("/api/requests")
    .send(newReq)
    .expect(200)
    .end (e, r) =>
      if e? then $log 'error', e
      newReq = und.clone r.body
      callback newReq


describe "REST api requests", ->

  before (done) ->
    @testNum = 0
    createDB done

  beforeEach ->
    @testNum++

  after (done) ->
    $log 'destroying...'
    destroyDB done

  it "should get first request", (done) ->
    createReq data.requests[1], (req) =>
      request(app)
        .get('/api/requests')
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

  it "should throw error if set to canceled with no detail", (done) ->
    errors = isServer: true, msg: "Update failed", data: { canceledDetail: "Must supply canceled reason" }
    createReq data.requests[3], (up) =>
      up.status = "canceled"
      request(app)
        .put("/api/requests/#{up._id}")
        .send(up)
        .expect(400)
        .end (err, res) ->
          expect( res.body ).to.deep.equal errors
          done()

  it "should add canceled event if status changed to canceled", (done) ->
    createReq data.requests[3], (up) =>
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
          expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'
          done()


  it "should throw error if set to incomplete with no message", (done) ->
    errors = isServer: true, msg: "Update failed", data: { incompleteDetail: "Must supply incomplete reason" }
    createReq data.requests[3], (up) =>
      up.status = "incomplete"
      request(app)
        .put("/api/requests/#{up._id}")
        .send(up)
        .expect(400)
        .end (err, res) ->
          expect( res.body ).to.deep.equal errors
          done()

  it "should add incomplete event if status changed to incomplete", (done) ->
    createReq data.requests[3], (up) =>
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
          expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'
          done()

  it "should add suggested event & update status to review when expert suggested by admin", (done) ->
    createReq data.requests[3], (up) =>
      suggestion = data.requests[4].suggested[0]
      up.suggested = [ suggestion ]
      request(app)
        .put("/api/requests/#{up._id}")
        .send(up)
        .expect(200)
        .end (err, res) ->
          d = res.body
          expect( d.events.length ).to.equal 2
          expect( d.events[1].name ).to.equal "suggested #{suggestion.expert.username}"
          expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'

          expect( d.status ).to.equal "review"

          expect( d.suggested.length ).to.equal 1
          expect( d.suggested[0].events.length ).to.equal 1
          expect( d.suggested[0].events[0].name ).to.equal "first contacted"
          expect( d.suggested[0].events[0].by.name ).to.equal 'Jonathon Kresner'

          expect( d.suggested[0].expertStatus ).to.equal "waiting"

          done()

  it "should add multiple suggested event", (done) ->
     createReq data.requests[3], (up) =>
      sug1 = data.requests[4].suggested[1]
      sug2 = data.requests[4].suggested[2]
      up.suggested = [ sug1, sug2 ]
      request(app)
        .put("/api/requests/#{up._id}")
        .send(up)
        .expect(200)
        .end (err, res) ->
          d = res.body
          expect( d.events.length ).to.equal 3
          expect( d.events[1].name ).to.equal "suggested #{sug1.expert.username}"
          expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'
          expect( d.events[2].name ).to.equal "suggested #{sug2.expert.username}"
          expect( d.events[2].by.name ).to.equal 'Jonathon Kresner'

          done()

  it "should add suggested removed event when expert removed by admin", (done) ->
    createReq data.requests[3], (up) =>
      suggestion = data.requests[4].suggested[0]
      up.suggested = [ suggestion ]
      request(app)
        .put("/api/requests/#{up._id}")
        .send(up)
        .expect(200)
        .end (err, res) ->
          upp = res.body
          upp.suggested = []
          request(app)
            .put("/api/requests/#{upp._id}")
            .send(upp)
            .end (errr, ress) ->
              d = ress.body
              expect( d.events.length ).to.equal 3
              expect( d.events[2].name ).to.equal "removed suggested #{suggestion.expert.username}"
              expect( d.events[2].by.name ).to.equal 'Jonathon Kresner'
              done()


  it "should add updated event if details updated by customer", (done) ->
    createReq data.requests[3], (up) =>
      up.brief = 'updating brief'
      request(app)
        .put("/api/requests/#{up._id}")
        .send(up)
        .expect(200)
        .end (err, res) ->
          d = res.body
          expect( d.brief ).to.equal 'updating brief'
          expect( d.events.length ).to.equal 2
          expect( d.events[1].name ).to.equal "updated"
          expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'

          done()

  it "should add viewed event if viewed by customer", (done) ->
   createReq data.requests[3], (up) =>
      request(app)
        .get("/api/requests/#{up._id}")
        .end (err, res) ->
          d = res.body
          expect( d.events.length ).to.equal 2
          expect( d.events[1].name ).to.equal "customer view"
          expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'
          request(app)
            .get("/api/requests/#{up._id}")
            .end (errr, ress) ->
              dd = ress.body
              expect( dd.events.length ).to.equal 3
              expect( dd.events[2].name ).to.equal "customer view"
              expect( dd.events[2].by.name ).to.equal 'Jonathon Kresner'
              done()

  it "should add viewed event if viewed by expert", (done) ->
    req = data.requests[3]
    req.suggested = [ data.requests[4].suggested[0] ]
    req.suggested[0].expert.userId = "51708da81dd90b04cddccc9e"
    req.suggested[0].expertStatus = "waiting"
    req.suggested[0].events = [{}]

    createReq req, (up) =>
      request(app)
        .get("/api/requests/#{up._id}")
        .end (err, res) ->
          d = res.body
          expect( d.events.length ).to.equal 2
          expect( d.events[1].name ).to.equal "expert view"
          expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'

          expect( d.suggested[0].events.length ).to.equal 2
          expect( d.suggested[0].events[1].name ).to.equal "viewed"

          request(app)
            .get("/api/requests/#{up._id}")
            .end (errr, ress) ->
              dd = ress.body
              expect( dd.events.length ).to.equal 3
              expect( dd.events[2].name ).to.equal "expert view"
              expect( dd.events[2].by.name ).to.equal 'Jonathon Kresner'
              done()


  # it "should add scheduled event call added", (done) ->

  # it "should add completed event if status changed to completed by customer", (done) ->
