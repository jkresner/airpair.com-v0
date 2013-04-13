require './../../test-setup'
mongoose = require 'mongoose'
request = require 'supertest'
express = require 'express'

data =
  skills: require './../../data/skills'

app = express()

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
    @skill = request(app)
      .post('/api/skills')
      .send( data.skills[testNum] )
      .expect(200, done)

  it "should get first skill", (done) ->
    request(app)
      .get('/api/skills')
      .expect('Content-Type', /json/)
      # .expect( [ data.skills[testNum] ] )
      .end done


  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done