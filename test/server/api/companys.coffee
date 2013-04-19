require './../test-lib-setup'
require './../test-app-setup'

data =
  companys: require './../../data/companys'

api_companys = require('./../../../lib/api/companys')(app)


describe "REST api companys", ->

  before (done) ->
    @testNum = 0
    mongoose.connect "mongodb://localhost/airpair_test", done

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
      .end done

  # it "can create company when authenticated", (done) ->
  #   request(app)
  #     .get('/api/users/me')
  #     .expect( { authenticated: false } )
  #     .end done

  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done