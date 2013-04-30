und = require 'underscore'
Request = require './../models/request'
v0_3_requests = require './data/v0.3/requests'

v0_3company =
  "name": "Test Co.", "url": "testing.airpair.com",
  "about": "We like to test airpair.com in a way that makes our systems safe, secure, fast and beautiful.\n\nWe approach testing as a trade off more than pure TDD. JavaScript is an amazing language, but is kind of dangerous so test coverage is important, but not at the expense of speed to market.\n\nSinon is a great framework and brunch comes with mocha-phantom support.",
  "contacts": [
    {
      "fullName": "Jon v0.3 Test",
      "email": "jkresner@yahoo.com.au", "gmail": "apv3test@gmail.com",
      "title": "", "phone": "",
      "userId": "5175ffbbbb888cc4d5aaa6aa",
      "pic": "https://lh3.googleusercontent.com/-NKYL9eK5Gis/AAAAAAAAAAI/AAAAAAAAABY/291KLuvT0iI/photo.jpg",
      "twitter": "aptest", "timezone": "GMT-0700 (PDT)"
    }
  ]

migrate = (d, all_tags, all_experts, all_users) ->

  r =
    _id: d._id
    userId: all_users[0]._id
    brief: d.brief
    canceledReason: d.canceledReason
    company: und.clone(v0_3company)
    calls: d.calls
    budget: 50
    hours: "1"
    pricing: "opensource"
    availability: []
    events: d.events
    status: d.status


  $log 'd.companyName', d.companyName
  if d.companyName? then r.company.name = d.companyName

  tags = []
  for s in d.skills
    t = und.find all_tags, (t) -> t.soId == s.soId
    if t?
      tags.push name: t.name, short: t.short, soId: t.soId, ghId: t.ghId
  r.tags = tags

  calls = []
  for c in d.calls
    t = c
    if t?
      t.expert = c.dev
      delete t.dev
      calls.push t
  r.calls = calls

  suggested = []
  for c in d.suggested
    t = und.find all_experts, (m) -> m._id.toString() is c.dev._id
    if t?
      e =
        _id: t._id
        name: t.name
        username: t.username
        email: t.email
        gmail: t.gmail
        pic: t.pic
        homepage: t.homepage
        other: t.other
        rate: 0
        so: t.so
        gh: t.gh
        karma: 0,
        tags: t.tags
      suggested.push expertStatus: 'waiting', expert: e, expertAvailability: [], events: c.events
  r.suggested = suggested
  r

# step 1 :: load in devs from v0 (to maintain original ids)
importRequestsV0_3 = (tags, experts, users, callback) ->
  count = 0
  for d in v0_3_requests
    new Request( migrate(d, tags, experts, users) ).save (e, r) =>
      if e? then $log "added[#{count}]", e, r
      count++
      if count == v0_3_requests.length-1 then callback()


module.exports = (tags, experts, users, callback) ->
  Request.find({}).remove ->
    $log 'r[0] requests removed'
    Request.collection.dropAllIndexes (e, r) ->
      $log "r[1] adding #{v0_3_requests.length} v0_3_requests"
      importRequestsV0_3 tags, experts, users, ->
        Request.find {}, (e, r) ->
          $log "r[2] saved #{r.length} requests"
          callback r