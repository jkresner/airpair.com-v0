require './../../test-setup'
require './../../test-http-setup'

data =
  users: require './../../data/users'


api_users = require './../../../api/users'

app.get     '/api/users/me', api_users.detail


describe "REST api users", ->

  before (done) ->
    @testNum = 0
    mongoose.connect "mongodb://localhost/airpair_test", done

  beforeEach (done) ->
    @testNum++
    @user = data.users[@testNum]
    done()

  it "should get unauthenticated json object when not logged in", (done) ->
    request(app)
      .get('/api/users/me')
      .expect( { authenticated: false } )
      .end done

  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done