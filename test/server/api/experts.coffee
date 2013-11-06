{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app,data,passportMock} = require './../test-app-setup'


require('./../../../lib/api/experts')(app)


describe "REST api experts", ->

  @testNum = 0
  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach -> @testNum++


  it "can get created expert", (done) ->
    @expert = data.experts[1]
    http(app).post('/api/experts')
      .send( @expert )
      .expect(200)
      .end (err, res) =>
        d = res.body
        expect(d.userId).to.equal @expert.userId
        expertId = res.body._id

        http(app).get("/api/experts/#{expertId}")
          .expect(200)
          .end (errr, ress) =>
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
