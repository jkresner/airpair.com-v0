global.$log = console.log

global.und = require 'underscore'
global.sinon = require 'sinon'
chai = require 'chai'
chai.use require 'sinon-chai'
#require "sinon/lib/sinon/util/fake_xml_http_request"

global.sinon = sinon
global.expect = chai.expect


global.createDB = (done) ->
  if suiteCtx?
    done()
  else
    mongoose.connect "mongodb://localhost/airpair_test", done

global.destroyDB = (done) ->
  if suiteCtx?
    done()
  else
    mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
      mongoose.connection.close done