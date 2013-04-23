und = require 'underscore'
Request = require './../models/request'
v0_3_requests = require './data/v0.3/requests'

migrate = (d, all_tags, all_experts, all_users) ->
  # username = 'unkonwn'
  # if d.gh? && d.gh != '' then username = d.gh
  # gmail = d.email
  # if d.gmail? d.gmail != '' then gmail = d.gmail

  r =
    _id: d._id
    userId: all_users[0]._id
  #   name: d.name
  #   username: username
  #   email: d.email
  #   gmail: gmail
  #   pic: d.pic
  #   homepage: d.homepage
  #   other: d.other
  #   rate: d.rate

  # if d.so? then e.so = link: d.so
  # if d.gh? then e.gh = username: d.gh

  # tags = []
  # for s in d.skills
  #   t = und.find all_tags, (t) -> t.soId == s.soId
  #   if t?
  #     # $log 'found tag match', t.name, s.name
  #     tags.push name: t.name, short: t.short, soId: t.soId, ghId: t.ghId
  # e.tags = tags
  r

# step 1 :: load in devs from v0 (to maintain original ids)
importRequestsV0_3 = (tags, experts, users, callback) ->
  count = 0
  for d in v0_3_requests
    r  = migrate(d, tags, experts, users)
    $log 'migrate', r
  # new Request( migrate(re, tags, experts) ).save (e, r) =>
    # if e? then
   # $log "added[#{count}]", e, r.name
  #     count++
  #     if count == v0_3_devs.length-1 then callback()
  callback()

module.exports = (tags, experts, users, callback) ->
  Request.find({}).remove ->
    $log 'r[0] requests removed', users
    Request.collection.dropAllIndexes (e, r) ->
      $log "r[1] adding #{v0_3_requests.length} v0_3_requests"
      importRequestsV0_3 tags, experts, users, ->
      Request.find {}, (e, r) ->
        $log "r[2] saved #{r.length} requests"
        callback r