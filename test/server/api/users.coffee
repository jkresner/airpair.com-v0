require './../test-lib-setup'
require './../test-app-setup'

data =
  users: require './../../data/users'


api_users = require './../../../lib/api/users'

auth = require './../../../lib/auth/base'
app.get     '/api/users/me', api_users.detail
app.get     '/auth/github', auth.github.connect
app.get     '/auth/github/callback', auth.github.connect, auth.github.done


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

  it "should get user object when logged in", (done) ->
    request(app)
      .get('/auth/github')
      .end (perr, pres) ->
        request(app)
          .get('/api/users/me')
          .end (gerr, gres) ->
            expect(gres.body).to.equal data.users[2]
            done()

  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done