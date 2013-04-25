require './../test-lib-setup'
require './../test-app-setup'

data:
  skillsv0_3 = require './../../../lib/bootstrap/data/v0.3/skills'

Tag = require './../../../lib/models/tag'



describe "BOOTSTRAP tags", ->

  before (done) ->
    @testNum = 0
    mongoose.connect "mongodb://localhost/airpair_test", done

  beforeEach (done) ->
    @testNum++
    done()

  it "new doc with _id keeps _id and has __v == 0", (done) ->
    brunch = name: "brunch", short: "brunch", soId: "brunch", _id: "514825fa2a26ea020000000b"
    new Tag( brunch ).save (e, r) ->
      $log 'tags.test.1', r._id is brunch._id, r._id, brunch._id
      expect( r._id.toString() ).to.equal brunch._id.toString()
      expect( r.name ).to.equal 'brunch'
      expect( r.short ).to.equal 'brunch'
      expect( r.soId ).to.equal 'brunch'
      expect( r.__v ).to.equal 0

      Tag.findOne { _id: "514825fa2a26ea020000000b" }, (ee, rr) ->
        $log 'tags.test.11', ee, rr
        expect( rr.name ).to.equal 'brunch'
        done()

  it "fails when adding tag with same soId twice", (done) ->
    test = name: "test", short: "test", soId: "testId"
    new Tag( test ).save (e, r) ->
      expect(e).to.equal undefined
      expect(r.soId).to.equal test.soId
      new Tag( test ).save (ee, rr) ->
        $log 'rr', rr
        expect(ee).to.not.equal undefined
        expect(rr).to.equal undefined



  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done