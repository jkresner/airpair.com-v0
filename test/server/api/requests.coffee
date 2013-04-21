require './../test-lib-setup'
require './../test-app-setup'

data =
  users: require './../../data/users'
  requests: require './../../data/requests'


api_skills = require('./../../../lib/api/requests')(app)


describe "REST api requests", ->

  before (done) ->
    @testNum = 0
    mongoose.connect "mongodb://localhost/airpair_test", done

  beforeEach (done) ->
    @testNum++
    @req = data.requests[@testNum]
    #console.log 'test', @testNum, @req.brief
    request(app)
      .post('/api/requests')
      .send( @req )
      .expect(200, done)

  it "should get first request", (done) ->
    req = @req
    request(app)
      .get('/api/requests')
      .end (err, res) ->
        d = res.body[0]
        # $log 'res', d
        expect(d.userId).to.equal data.users[0]._id
        expect(d.events.length).to.equal 1
        expect(d.company.name).to.equal req.company.name
        expect(d.company.contacts.length).to.equal 1
        expect(d.status).to.equal 'received'
        expect(d.hours).to.equal req.hours
        expect(d.brief).to.equal req.brief
        expect(d.budget).to.equal req.budget
        expect(d.pricing).to.equal req.pricing
        expect(d.availability.length).to.equal 2
        done()

  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done