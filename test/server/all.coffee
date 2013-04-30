mongoose = require 'mongoose'
global.suiteCtx = true

describe "Server-side suit", ->

  before (done) ->
    console.log 'running server suite'
    mongoose.connect "mongodb://localhost/airpair_test", done

  describe 'api/companys', (done) -> require('./api/companys')
  describe 'api/experts', (done) -> require('./api/experts')
  describe 'api/requests', (done) -> require('./api/requests')
  describe 'api/users', (done) -> require('./api/users')
  describe 'auth/connect', (done) -> require('./auth/connect')
  describe 'bootstrap/tags', (done) -> require('./bootstrap/tags')

  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      console.log 'ran server tests & destroyed DB'
      mongoose.connection.close done