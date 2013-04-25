require './../test-lib-setup'
require './../test-app-setup'

data =
  requests: require './../../data/requests'

Request = require './../../../lib/models/request'



describe "BOOTSTRAP requests", ->

  before (done) ->
    @testNum = 0
    mongoose.connect "mongodb://localhost/airpair_test", done

  beforeEach (done) ->
    @testNum++
    done()

  it "add a request with an expert saves whole expert", (done) ->
    request = data.requests[2]

    new Request( request ).save (e, r) ->
      expect( r.suggested.length ).to.equal 1
      expect( r.suggested[0].expert._id ).to.equal "5173116b1dd90b04cddccce4"

      Request.findOne {'_id': "515a60284bfa2f0200000052"}, (ee, rr) ->
        expect( rr.suggested[0].expert._id ).to.equal "5173116b1dd90b04cddccce4"
        done()

  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done