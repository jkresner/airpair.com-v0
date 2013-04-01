expect = require 'expect.js'

# module.exports =
#   expect: expect

chai = require 'chai'
sinonChai = require 'sinon-chai'
chai.use sinonChai
sinon = require('sinon')
global.sinon = sinon
require("sinon/lib/sinon/util/fake_xml_http_request")

module.exports =
  # expect: chai.expect
  sinon: sinon
  fixtures: require('js-fixtures')