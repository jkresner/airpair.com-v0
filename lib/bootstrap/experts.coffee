request = require 'superagent'
Expert = require './../models/expert'
Tag = require './../models/tag'
v0_devs = require './data/v0/dev'


Expert.find({}).remove()
$log 'experts removed'
$log "#{v0_devs.length} v0_devs"

all_tags = Tag.find({})

migrate = (d) ->
  e =
    _id: d._id
    name: d.name
    username: d.gh
    email: d.email
    gmail: d.gmail
    pic: d.pic
    homepage: d.homepage
    other: d.other
    rate: d.rate

    # consciously decided not migrate linkedin & bitbucket

    if d.so then e.so = { link: d.so }
    if d.gh then e.hg = { username: d.gh }

    tags = []
    for s in d.skills
      t = und.find all_tags, (t) -> t._id == s._id
      tags.push name: t.name, short: t.short, soId: t.soId, ghId: t.ghId
    e.tags = tags
  e

# step 1 :: load in devs from v0 (to maintain original ids)
importDevsV0 = (callback) ->
  count = 0
  for d in v0_devs
    new Expert( migrate(d) ).save (e, r) =>
      $log "added.expert[#{count}]", r.name
      count++
      if count == v0_devs.length then callback()

module.exports = ->

  importDevsV0 ->