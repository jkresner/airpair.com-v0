require './../test-lib-setup'
require './../test-app-setup'

data =
  companys: require './../../data/companys'

api_companys = require('./../../../lib/api/companys')(app)

describe "REST api companys", ->

  before (done) ->
    @testNum = 0
    createDB done

  beforeEach (done) ->
    @testNum++
    @company = data.companys[@testNum]
    done()

  it "can not create company if not authenticated", (done) ->
    request(app)
      .post('/api/companys/')
      .set('Accept', 'application/json')
      .send(@company)
      .expect(403)
      .expect({})
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

  after (done) ->
    destroyDB done