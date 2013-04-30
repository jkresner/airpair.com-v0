require './../test-lib-setup'
require './../test-app-setup'

data =
  users: require './../../data/users'


User = require './../../../lib/models/user'
api_users = require './../../../lib/api/users'

describe "REST api users", ->

  before (done) ->
    @testNum = 0
    createDB done

  beforeEach (done) ->
    @testNum++
    @user = data.users[@testNum]
    done()

  # it "should get unauthenticated json object when not logged in", (done) ->
  #   request(app)
  #     .get('/api/users/me')
  #     .expect( { authenticated: false } )
  #     .end done

  # it "should get user object when logged in", (done) ->
  #   request(app)
  #     .get('/api/users/me')
  #     .end (gerr, gres) ->
  #       expect(gres.body).to.equal data.users[0]
  #       done()

  after (done) ->
    destroyDB done