und = require 'underscore'
Request = require './../models/request'
v0_3_requests = require './data/v0.3/requests'

migrate = (d, all_tags, all_experts, all_users) ->

  r =
    _id: d._id
    userId: all_users[0]._id
    brief: d.brief
    canceledReason: d.canceledReason
    company: { _id: d.companyId, name: d.companyName }
    calls: d.calls
    budget: 50
    hours: "1"
    pricing: "opensource"
    availability: []
    events: d.events
    status: d.status

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
      delete t.expert
      calls.push t
  r.calls = calls

  suggested = []
  for c in d.suggested
    t = c
    if t?
      t.expert = c.dev
      delete t.expert
      suggested.push t
  r.suggested = suggested
  r

# step 1 :: load in devs from v0 (to maintain original ids)
importRequestsV0_3 = (tags, experts, users, callback) ->
  count = 0
  for d in v0_3_requests
    new Request( migrate(d, tags, experts, users) ).save (e, r) =>
      if e? then $log "added[#{count}]", e, r._id
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