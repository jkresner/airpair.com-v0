global.$log = console.log
global._ = require 'underscore'

async = require 'async'
mongoose = require 'mongoose'
chai = require 'chai'
chai.use require 'sinon-chai'

Factory = require 'factory-lady'
require ("../factory/expertFactory")
require ("../factory/requestFactory")
require ("../factory/orderFactory")

before (done) ->
  return done() if mongoose.connections[0]._listening
  mongoose.connection.once 'connected', done
  mongoose.connect 'localhost/airpair_test'

afterEach (done) ->
  async.each _.values(mongoose.connection.collections),
    (collection, callback) ->
      collection.remove callback
    , (err) ->
      done()

chai.Assertion.includeStack = true

module.exports =

  http:       require 'supertest'
  _:          require 'underscore'
  sinon:      require 'sinon'
  chai:       require 'chai'
  expect:     chai.expect
  Factory:    Factory
