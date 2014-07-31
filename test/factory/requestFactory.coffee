global._ = require 'lodash'
Factory = require('factory-lady')
Request = require('../../lib/models/request')

defaults =
  userId: '41224d776a326fb40f000001'
  company: 'Newbies, LLC'
  brief: 'Help me deploy my Rails app on my own VPN'
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

