global._ = require 'underscore'
Factory = require('factory-lady')
Expert = require('../../lib/models/expert')

require('./userFactory')

defaults = {
  name: 'An Expert'
  username: 'anexpert'
  email: 'an@experts.com'
  gmail: 'an@gmail.com'
  rate: 100
  pic: 'http://adfskljadlkjadfs.adfljadsfljadfs.com'
  karma: 1
}

Factory.define 'expert', Expert, defaults

dhhExpert = _.extend {}, defaults,
  name: 'David Hansson'
  email: 'dhh@experts.com'
  rate: 50
  tags: [{"soId":"ruby","short":"ruby","name":"Ruby","_id":"514825fa2a26ea0200000031", "subscription": { custom: ["advanced"], auto: ["advanced"] } },{"soId":"ruby-on-rails","short":"ruby-on-rails","name":"ruby-on-rails","_id":"514825fa2a26ea020000002f", "subscription": {}} ]
  user: (cb) ->
    Factory.create 'dhhUser', (dhhUser) ->
      cb(dhhUser.id)


Factory.define 'dhhExpert', Expert, dhhExpert

aslakExpert = _.extend {}, defaults,
  name: 'Aslak Hellesoy'
  email: 'aslak@experts.com'
  rate: 100
  tags: [ {"soId":"ruby","short":"ruby","name":"Ruby","_id":"514825fa2a26ea0200000031", "subscription": { custom: ["beginner", "intermediate", "advanced"], auto: ["beginner", "advanced"] } }, {"soId":"cucumber","short":"cucumber","name":"cucumber","_id":"5181d0aa66a6f999a465ee0b", "subscription": { custom: ["beginner", "intermediate", "advanced"], auto: ["beginner", "advanced"] } }  ]

Factory.define 'aslakExpert', Expert, aslakExpert
