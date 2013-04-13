require './../../test-setup'
require './../../test-http-setup'

data =
  skills: require './../../data/skills'

api_skills = require './../../../api/skills'

app.get     '/api/skills', api_skills.list
app.get     '/api/skills/:id', api_skills.detail
app.post    '/api/skills', api_skills.post
app.put     '/api/skills/:id', api_skills.update
app.put     '/api/skills/:id', api_skills.delete

testNum = 0

describe "REST update with mongoose", ->

  before (done) ->
    mongoose.connect "mongodb://localhost/airpair_test", done

  beforeEach (done) ->
    testNum = testNum + 1
    @skillNum = data.skills[testNum]
    @skill = request(app)
      .post('/api/skills')
      .send( @skillNum )
      .expect(200, done)

  it "should get first skill", (done) ->
    request(app)
      .get('/api/skills')
      .expect( [ @skillNum ] )
      .end done

  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done