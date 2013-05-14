global.$log = console.log


mongoose      = require 'mongoose'
chai          = require 'chai'
chai.use require 'sinon-chai'
#require "sinon/lib/sinon/util/fake_xml_http_request"


connect = (done) ->
  return done() if mongoose.connections[0]._listening
  mongoose.connect 'localhost/airpair_test', done

destroy = (done) ->
  return done() if suiteCtx?  # set in /test/server/all.coffee
  mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (e, r) ->
    mongoose.connection.close done


module.exports =
  http:       require 'supertest'
  _:          require 'underscore'
  sinon:      require 'sinon'
  chai:       require 'chai'
  expect:     chai.expect
  dbConnect:  connect
  dbDestroy:  destroy