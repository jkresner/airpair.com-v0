{http,_,sinon,chai,expect} = require './../test-lib-setup'
{app,data,passportMock} = require './../test-app-setup'


require('./../../../lib/api/experts')(app)

ExpertsService = require('./../../../lib/services/experts')
svc = new ExpertsService

describe "REST api experts", ->
  it "can update expert with tags and subscriptions", (done) ->
    mvh = data.experts[8]  # Matt Van Horn
    svc.create mvh, (e,r) ->
      console.log e
      # mutate Matt's subscription before PUT'ing him back in the db
      mvh.tags.push {"soId":"angular","short":"angular","name":"angular", "subscription": {auto: ["beginner"]}}

      http(app).put("/api/experts/#{r.id}")
        .send(mvh)
        .expect(200)
        .end (err, res) =>
          if err then return done err
          tag = _.find res.body.tags, (tag) ->
            tag.soId == "angular"

          expect(tag.subscription.auto).to.include("beginner")
          done()

  it "can get created expert", (done) ->
    @timeout 10000
    @expert = data.experts[1]
    http(app).post('/api/experts')
      .send( @expert )
      .expect(200)
      .end (err, res) =>
        if err then return done err
        d = res.body
        expect(d.userId).to.equal @expert.userId
        expertId = res.body._id

        http(app).get("/api/experts/#{expertId}")
          .expect(200)
          .end (err, ress) =>
            if err then return done err
            d = res.body
            expect(d.userId).to.equal @expert.userId
            expect(d.name).to.equal @expert.name
            expect(d.email).to.equal @expert.email
            expect(d.gmail).to.equal @expert.gmail
            expect(d.pic).to.equal @expert.pic
            expect(d.homepage).to.equal @expert.homepage
            expect(d.timezone).to.equal @expert.timezone
            expect(d.in).to.deep.equal @expert.in
            expect(d.tw).to.deep.equal @expert.tw
            expect(d.so).to.deep.equal @expert.so
            expect(d.bb).to.deep.equal @expert.bb
            done()

  # it "un-associated expert gets associated when user logs in first time", (done) ->
