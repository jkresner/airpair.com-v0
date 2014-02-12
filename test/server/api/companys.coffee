{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app,data,passportMock}                        = require './../test-app-setup'


require('./../../../lib/api/companys')(app)


describe "REST api companys", ->

  @testNum = 0
  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach -> @testNum++


  it "can not create company if not authenticated", (done) ->
    passportMock.setSession 'anon'
    @company = data.companys[1]
    http(app).post('/api/companys/')
      .set('Accept', 'application/json')
      .send(@company)
      .expect(403)
      .expect({})
      .end done

  it "creates company if authenticated", (done) ->
    @timeout 20000
    passportMock.setSession 'jk'
    @company = data.companys[1]
    http(app).post('/api/companys/')
      .set('Accept', 'application/json')
      .send(@company)
      .expect(200)
      .end (err, res) =>
        d = res.body
        expect(d.name).to.equal @company.name
        expect(d.url).to.equal @company.url
        expect(d.about).to.equal @company.about
        c = res.body.contacts[0]
        cc = @company.contacts[0]
        expect(c.userId).to.equal cc.userId
        expect(c.pic).to.equal cc.pic
        expect(c.fullName).to.equal cc.fullName
        expect(c.email).to.equal cc.email
        expect(c.gmail).to.equal cc.gmail
        expect(c.timezone).to.equal cc.timezone
        expect(c.title).to.deep.equal cc.title
        expect(c.phone).to.deep.equal cc.phone
        expect(c.twitter).to.deep.equal cc.twitter
        done()
