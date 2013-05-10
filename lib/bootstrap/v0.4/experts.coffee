
und = require 'underscore'
Expert = require './../models/expert'
v0_3_devs = require './data/v0.3/devs'

migrate = (d, all_tags) ->
  username = 'unkonwn'
  if d.gh? && d.gh != '' then username = d.gh
  gmail = d.email
  if d.gmail? d.gmail != '' then gmail = d.gmail

  e =
    _id: d._id
    name: d.name
    username: username
    email: d.email
    gmail: gmail
    pic: d.pic
    homepage: d.homepage
    other: d.other
    rate: d.rate

    # consciously decided not migrate linkedin & bitbucket

  if d.so? then e.so = link: d.so
  if d.gh? then e.gh = username: d.gh

  tags = []
  for s in d.skills
    t = und.find all_tags, (t) -> t.soId == s.soId
    if t?
      # $log 'found tag match', t.name, s.name
      tags.push name: t.name, short: t.short, soId: t.soId, ghId: t.ghId
  e.tags = tags
  e

# step 1 :: load in devs from v0 (to maintain original ids)
importDevsV0 = (tags, callback) ->
  count = 0
  for d in v0_3_devs
    new Expert( migrate(d, tags) ).save (e, r) =>
      # if e? then
      #$log "added[#{count}]", e, r.name
      count++
      if count == v0_3_devs.length-1 then callback()

module.exports = (tags, callback) ->
  Expert.find({}).remove ->
    $log 'e[0] experts removed'
    Expert.collection.dropAllIndexes (e, r) ->
      $log "e[1] adding #{v0_3_devs.length} v0_3_devs"
      importDevsV0 tags, ->
        Expert.find {}, (e, r) ->
          $log "e[2] saved #{r.length} experts"
          callback r
