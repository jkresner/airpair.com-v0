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


describe "REST api requests", ->
  @testNum = 0

  before (done) -> dbConnect done
  after (done) -> dbDestroy done
  beforeEach -> @testNum++

  it "should get first request", (done) ->
    passportMock.setSession 'admin'
    createReq data.requests[1], (req) =>
      http(app).get('/api/requests')
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
    passportMock.setSession 'admin'
    errors = isServer: true, msg: "Update failed", data: { canceledDetail: "Must supply canceled reason" }
    createReq data.requests[3], (up) =>
      up.status = "canceled"
      http(app).put("/api/requests/#{up._id}")
        .send(up)
        .expect(400)
        .end (err, res) ->
          expect( res.body ).to.deep.equal errors
          done()

  it "should add canceled event if status changed to canceled", (done) ->
    passportMock.setSession 'admin'
    createReq data.requests[3], (up) =>
      up.status = "canceled"
      up.canceledDetail = "testing babay"
      http(app).put("/api/requests/#{up._id}")
        .send(up)
        .expect(200)
        .end (err, res) ->
          d = res.body
          expect( d.events.length ).to.equal 2
          expect( d.events[1].name ).to.equal 'canceled'
          expect( d.events[1].by.name ).to.equal 'Airpair Kresner'
          done()


  it "should throw error if set to incomplete with no message", (done) ->
    passportMock.setSession 'admin'
    errors = isServer: true, msg: "Update failed", data: { incompleteDetail: "Must supply incomplete reason" }
    createReq data.requests[3], (up) =>
      up.status = "incomplete"
      http(app).put("/api/requests/#{up._id}")
        .send(up)
        .expect(400)
        .end (err, res) ->
          expect( res.body ).to.deep.equal errors
          done()

  it "should add incomplete event if status changed to incomplete", (done) ->
    passportMock.setSession 'admin'
    createReq data.requests[3], (up) =>
      up.status = "incomplete"
      up.incompleteDetail = "testing babay"
      http(app).put("/api/requests/#{up._id}")
        .send(up)
        .expect(200)
        .end (err, res) ->
          d = res.body
          expect( d.events.length ).to.equal 2
          expect( d.events[1].name ).to.equal 'incomplete'
          expect( d.events[1].by.name ).to.equal 'Airpair Kresner'
          done()

  it "should add suggested event & update status to review when expert suggested by admin", (done) ->
    passportMock.setSession 'admin'
    createReq data.requests[3], (up) =>
      suggestion = data.requests[4].suggested[0]
      up.suggested = [ suggestion ]
      http(app).put("/api/requests/#{up._id}")
        .send(up)
        .expect(200)
        .end (err, res) ->
          d = res.body
          expect( d.events.length ).to.equal 2
          expect( d.events[1].name ).to.equal "suggested #{suggestion.expert.username}"
          expect( d.events[1].by.name ).to.equal 'Airpair Kresner'

          expect( d.status ).to.equal "review"

          expect( d.suggested.length ).to.equal 1
          expect( d.suggested[0].events.length ).to.equal 1
          expect( d.suggested[0].events[0].name ).to.equal "first contacted"
          expect( d.suggested[0].events[0].by.name ).to.equal 'Airpair Kresner'

          expect( d.suggested[0].expertStatus ).to.equal "waiting"

          done()

  it "should add multiple suggested event", (done) ->
    passportMock.setSession 'admin'
    createReq data.requests[3], (up) =>
      sug1 = data.requests[4].suggested[1]
      sug2 = data.requests[4].suggested[2]
      up.suggested = [ sug1, sug2 ]
      http(app).put("/api/requests/#{up._id}")
        .send(up)
        .expect(200)
        .end (err, res) ->
          d = res.body
          expect( d.events.length ).to.equal 3
          expect( d.events[1].name ).to.equal "suggested #{sug1.expert.username}"
          expect( d.events[1].by.name ).to.equal 'Airpair Kresner'
          expect( d.events[2].name ).to.equal "suggested #{sug2.expert.username}"
          expect( d.events[2].by.name ).to.equal 'Airpair Kresner'

          done()

  it "should add suggested removed event when expert removed by admin", (done) ->
    passportMock.setSession 'admin'
    createReq data.requests[3], (up) =>
      suggestion = data.requests[4].suggested[0]
      up.suggested = [ suggestion ]
      http(app).put("/api/requests/#{up._id}")
        .send(up)
        .expect(200)
        .end (err, res) ->
          upp = res.body
          upp.suggested = []
          http(app).put("/api/requests/#{upp._id}")
            .send(upp)
            .end (errr, ress) ->
              d = ress.body
              expect( d.events.length ).to.equal 3
              expect( d.events[2].name ).to.equal "removed suggested #{suggestion.expert.username}"
              expect( d.events[2].by.name ).to.equal 'Airpair Kresner'
              done()


  it "should add updated event if details updated by customer", (done) ->
    passportMock.setSession 'jk'
    createReq data.requests[3], (up) =>
      up.brief = 'updating brief'
      http(app).put("/api/requests/#{up._id}")
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
    passportMock.setSession 'jk'
    createReq data.requests[3], (up) =>
      http(app).get("/api/requests/#{up._id}") .end () ->
        http(app).get("/api/requests/#{up._id}").end () ->
          passportMock.setSession 'admin'

          http(app).get("/api/requests/#{up._id}")
            .end (e, r) ->
              d = r.body
              expect( d.events.length ).to.equal 3
              expect( d.events[1].name ).to.equal "customer view"
              expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'
              expect( d.events[2].name ).to.equal "customer view"
              expect( d.events[2].by.name ).to.equal 'Jonathon Kresner'
              done()

  it "adds viewed event if viewed by expert", (done) ->
    passportMock.setSession 'jk'
    req = data.requests[3]

    req.suggested = [ data.requests[4].suggested[0] ]
    req.suggested[0].expert.userId = "5181d1f666a6f999a465f280"
    req.suggested[0].expertStatus = "waiting"
    req.suggested[0].events = [{}]

    createReq req, (up) =>
      http(app).get("/api/requests/#{up._id}").end () ->
        http(app).get("/api/requests/#{up._id}").end () ->

          passportMock.setSession 'admin'
          http(app).get("/api/requests/#{up._id}").end (e, r) ->

            d = r.body
            expect( d.suggested[0].events.length ).to.equal 3
            expect( d.suggested[0].events[1].name ).to.equal "viewed"
            expect( d.events.length ).to.equal 3
            expect( d.events[1].name ).to.equal "expert view"
            expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'
            expect( d.events[2].name ).to.equal "expert view"
            expect( d.events[2].by.name ).to.equal 'Jonathon Kresner'
            done()


  it "can update suggestion by expert", (done) ->
    passportMock.setSession 'artjumble'
    req = data.requests[3]
    req.suggested = [ data.requests[4].suggested[0] ]
    req.suggested[0].expert.userId = "5181d1f666a6f999a465f280"
    req.suggested[0].expertStatus = "waiting"
    req.suggested[0].events = [{}]

    createReq req, (up) =>
      ups = expertStatus: 'abstained', expertFeedback: 'not for me', expertRating: 1, expertComment: 'good luck', expertAvailability: 'I can do tonight'
      passportMock.setSession 'jk'
      http(app).put("/api/requests/#{up._id}/suggestion")
        .send(ups)
        .end () ->
          passportMock.setSession 'admin'
          http(app).get("/api/requests/#{up._id}").end (e, r) ->
            d = r.body

            expect( d.events.length ).to.equal 2
            expect( d.events[1].name ).to.equal "expert reviewed"
            expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'

            expect( d.suggested[0].expertStatus ).to.equal = ups.expertStatus
            expect( d.suggested[0].expertFeedback ).to.equal = ups.expertFeedback
            expect( d.suggested[0].expertRating ).to.equal = ups.expertRating
            expect( d.suggested[0].expertComment ).to.equal = ups.expertComment
            expect( d.suggested[0].expertAvailability ).to.equal = ups.expertAvailability

            expect( d.suggested[0].events.length ).to.equal = 2
            expect( d.suggested[0].events[1].name ).to.equal = "expert updated"

            done()


  it "can update suggestion by customer", (done) ->
    passportMock.setSession 'jk'
    req = data.requests[3]
    sug = data.requests[4].suggested[0]
    req.suggested = [ data.requests[4].suggested[0] ]
    req.suggested[0].expertStatus = "waiting"
    req.suggested[0].events = [{}]

    createReq req, (up) =>
      ups = expert: sug.expert , expertStatus: 'unwanted', customerFeedback: 'no way', expertRating: 1

      http(app).put("/api/requests/#{up._id}/suggestion")
        .send(ups)
        .end (err, res) ->
          d = res.body
          expect( d.events.length ).to.equal 2
          expect( d.events[1].name ).to.equal "customer expert review"
          expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'

          expect( d.suggested[0].expertStatus ).to.equal = 'unwanted'
          expect( d.suggested[0].customerFeedback ).to.equal = ups.customerFeedback
          expect( d.suggested[0].customerRating ).to.equal = ups.customerRating

          expect( d.suggested[0].events.length ).to.equal = 2
          expect( d.suggested[0].events[1].name ).to.equal = "customer updated"

          done()


  it "can say no to suggestion by expert", (done) ->
    passportMock.setSession 'admin'
    req = data.requests[5]

    createReq req, (up) =>
      passportMock.setSession 'jk'

      ups = data.requests[6].nothanks

      http(app).put("/api/requests/#{up._id}/suggestion")
        .send(ups)
        .end (err, res) ->
          d = res.body

          expect( d.events.length ).to.equal 2
          expect( d.events[1].name ).to.equal "expert reviewed"
          expect( d.events[1].by.name ).to.equal 'Jonathon Kresner'

          expect( d.suggested[0].expertStatus ).to.equal = ups.expertStatus
          expect( d.suggested[0].expertFeedback ).to.equal = ups.expertFeedback
          expect( d.suggested[0].expertRating ).to.equal = ups.expertRating
          expect( d.suggested[0].expertComment ).to.equal = ups.expertComment
          expect( d.suggested[0].expertAvailability ).to.equal = ups.expertAvailability

          expect( d.suggested[0].events.length ).to.equal = 2
          expect( d.suggested[0].events[1].name ).to.equal = "expert updated"

          done()


  # it "should add scheduled event call added", (done) ->

  # it "should add completed event if status changed to completed by customer", (done) ->
