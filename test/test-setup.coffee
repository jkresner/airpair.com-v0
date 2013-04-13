#expect = require 'expect.js'

# module.exports =
#   expect: expect

sinon = require 'sinon'
chai = require 'chai'
chai.use require 'sinon-chai'
#require "sinon/lib/sinon/util/fake_xml_http_request"

global.sinon = sinon
global.expect = chai.expect

# module.exports =
#   expect: chai.expect
#   sinon: sinon


  #fixtures: require('js-fixtures')