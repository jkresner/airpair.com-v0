
# if we're in node, require libraries
if typeof window is 'undefined'

  console.log 'global', global
  global.und = require 'underscore'
  global.sinon = require 'sinon'
  chai = require 'chai'
  chai.use require 'sinon-chai'
  #require "sinon/lib/sinon/util/fake_xml_http_request"

  global.sinon = sinon
  global.expect = chai.expect