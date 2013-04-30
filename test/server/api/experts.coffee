require './../test-lib-setup'
require './../test-app-setup'

data =
  experts: require './../../data/experts'

api_experts = require('./../../../lib/api/experts')(app)

describe "REST api experts", ->

  before (done) ->
    @testNum = 0
    createDB done

  beforeEach (done) ->
    @testNum++
    @expert = data.experts[@testNum]
    request(app)
      .post('/api/experts')
      .send( @expert )
      .expect(200)
      .end (err, res) =>
        d = res.body
        expect(d.userId).to.equal @expert.userId
        @expertId = res.body._id
        done()

  it "can get created expert", (done) ->
    expert = @expert
    request(app)
      .get("/api/experts/#{@expertId}")
      .expect(200)
      .end (err, res) =>
        d = res.body
        expect(d.userId).to.equal @expert.userId
        expect(d.name).to.equal @expert.name
        expect(d.email).to.equal @expert.email
        expect(d.gmail).to.equal @expert.gmail
        expect(d.pic).to.equal @expert.pic
        expect(d.homepage).to.equal @expert.homepage
        expect(d.timezone).to.equal @expert.timezone
        expect(d.in).to.deep.equal @expert.in
        expect(d.tw).to.deep.equal expert.tw
        expect(d.so).to.deep.equal expert.so
        expect(d.bb).to.deep.equal expert.bb
        done()

  # it "un-associated expert gets associated when user logs in first time", (done) ->



  after (done) ->
    destroyDB done