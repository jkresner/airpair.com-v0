global._ = require 'underscore'
Factory = require('factory-lady')
Request = require('../../lib/models/request')

defaults =
  userId: '41224d776a326fb40f000001'
  company: 'anexpert'
  brief: 'daskjlkja a fdjadfkj adfjlkadf jadfl adf jlajlkadfs jlkj adfj ladflskjlkj adfjladfjljkl daf jkladfjkl adf'
  status: 'received'
  budget: 100
  pricing: 'private'
  hours: 'a lot'
  events: {}
  tags: []

Factory.define 'request', Request, defaults

Factory.define 'rails-request', Request,
  _.extend( {}, defaults, tags: [{"soId":"ruby","short":"ruby","name":"Ruby Motion","_id":"514825fa2a26ea0200000031"},
                                  {"soId":"ruby-on-rails","short":"ruby-on-rails","name":"ruby-on-rails","_id":"514825fa2a26ea020000002f"}] )

