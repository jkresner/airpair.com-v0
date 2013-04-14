require './../../test-setup'
require './../../test-http-setup'

data =
  skills: require './../../data/skills'


api_skills = require './../../../api/skills'

app.get     '/api/skills', api_skills.list
app.get     '/api/skills/:id', api_skills.detail
app.post    '/api/skills', api_skills.create
app.put     '/api/skills/:id', api_skills.update
app.delete  '/api/skills/:id', api_skills.delete

describe "REST api skills", ->

  before (done) ->
    @testNum = 0
    mongoose.connect "mongodb://localhost/airpair_test", done

  beforeEach (done) ->
    @testNum++
    @skill = data.skills[@testNum]
    #console.log 'test', @testNum, @skill.name, @skill._id
    request(app)
      .post('/api/skills')
      .send( @skill )
      .expect(200, done)

  it "should get first skill", (done) ->
    request(app)
      .get('/api/skills')
      .expect( [ @skill ] )
      .end done

  it "should update skill shortName", (done) ->
    id = @skill._id
    update = und.clone @skill
    update.shortName = 'testUpdate'
    request(app)
      .put('/api/skills/'+id)
      .send( update )
      .end (perr, pres) ->
        expect(pres.body.shortName).to.equal 'testUpdate'
        request(app)
          .get('/api/skills/'+id)
          .end (gerr, gres) ->
            expect(gres.body.shortName).to.equal 'testUpdate'
            done()

  it "should delete third skill", (done) ->
    id = @skill._id
    request(app)
      .del('/api/skills/'+id)
      .end (perr, pres) ->
        request(app)
          .get('/api/skills')
          .end (gerr, gres) ->
            match = und.find gres.body, (m) -> m._id == id
            expect(match).to.equal undefined
            done()

  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done