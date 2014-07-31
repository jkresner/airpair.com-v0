global._ = require 'lodash'
Factory = require('factory-lady')
Expert = require('../../lib/models/expert')

require('./userFactory')

Factory.define 'expert', Expert, defaults =
  name: 'An Expert'
  username: 'anexpert'
  email: 'an@experts.com'
  gmail: 'an@gmail.com'
  rate: 100
  pic: 'http://adfskljadlkjadfs.adfljadsfljadfs.com'
  karma: 1

Factory.define 'dhhExpert', Expert, _.extend {}, defaults,
  name: 'David Hansson'
  email: 'dhh@experts.com'
  rate: 50
  tags: [
    soId:"ruby"
    levels: ["advanced"]
  ,
    soId: "ruby-on-rails"
    levels: ["intermediate","advanced"]
  ]

Factory.define 'aslakExpert', Expert, _.extend {}, defaults,
  name: 'Aslak Hellesoy'
  email: 'aslak@experts.com'
  rate: 100
  tags: [
    soId:"ruby"
    levels: ["intermediate","advanced"]
  ,
    soId: "cucumber"
    levels: ["beginner","intermediate","advanced"]
  ]
