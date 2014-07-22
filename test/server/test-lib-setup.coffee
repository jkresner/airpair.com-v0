global.$log = console.log
global._ = require 'lodash'

mongoose = require 'mongoose'
chai = require 'chai'
chai.use require 'sinon-chai'

Factory = require 'factory-lady'
require ("../factory/expertFactory")
require ("../factory/requestFactory")

before (done) ->
  return done() if mongoose.connections[0]._listening
  mongoose.connection.once 'connected', done
  mongoose.connect 'localhost/airpair_test'

afterEach (done) ->
  if mongoose.connection.db?
    mongoose.connection.db.dropDatabase done
  else
    done()

chai.Assertion.includeStack = true

module.exports =

  http:       require 'supertest'
  _:          require 'lodash'
  sinon:      require 'sinon'
  chai:       require 'chai'
  expect:     chai.expect
  Factory:    Factory
