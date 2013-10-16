global.suiteCtx = true
mongoose = require 'mongoose'

describe "Server-side suite", ->

  before (done) ->
    mongoose.connect "mongodb://localhost/airpair_test", ->
      mongoose.connection.db.executeDbCommand { dropDatabase:1 }, done

  describe 'ui/models/request', (done) -> require './ui/models/request'
  describe 'api/companys', (done) -> require './api/companys'
  describe 'api/experts', (done) -> require './api/experts'
  describe 'api/requests', (done) -> require './api/requests'
  describe 'services/rates', (done) -> require './services/rates'
  describe 'services/request', (done) -> require './services/request'


  after (done) ->
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      console.log 'ran server tests & destroyed DB'
      mongoose.connection.close done