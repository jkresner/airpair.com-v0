global.$log = console.log


mongoose      = require 'mongoose'
chai          = require 'chai'
chai.use require 'sinon-chai'
#require "sinon/lib/sinon/util/fake_xml_http_request"

chai.Assertion.includeStack = true

connect = (done) ->
  return done() if mongoose.connections[0]._listening
  mongoose.connection.once 'connected', done
  mongoose.connect 'localhost/airpair_test'

destroy = (mocha, done) ->
  return done() if suiteCtx?  # set in /test/server/all.coffee
  # db destruction takes a long time
  mocha.timeout 5000
  mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (e, r) ->
    if e then return done e
    mongoose.connection.close done

module.exports =
  http:       require 'supertest'
  _:          require 'underscore'
  sinon:      require 'sinon'
  chai:       require 'chai'
  expect:     chai.expect
  dbConnect:  connect
  dbDestroy:  destroy
