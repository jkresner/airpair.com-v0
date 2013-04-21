request = require 'superagent'
Tag = require './../models/tag'
v0_skillsdata = require './data/v0/skills'
stackoverflow_tagdata = require './data/stackoverflow/tags'



Tag.find({}).remove()
$log 'tags removed'

$log "#{v0_skillsdata.length} v0_skillsdata"

# step 1 :: load in skills from v0 (to maintain original ids)
importSkillsV0 = (callback) ->
  count = 0
  for s in v0_skillsdata
    tag = name: s.name, short: s.shortName, soId: s.soId, _id: s._id
    new Tag( tag ).save (e, r) =>
      $log "added.tag[#{count}]", r.name
      count++
      if count == v0_skillsdata.length then callback()

# step 2 :: run stack exchange import (findOneAndUpdate)
importTop2000StackoverflowTags = (callback) ->

  $log 'importTop2000StackoverflowTags'

  # for i in [1...50]
  #   vector = ''

  #   for j in [0...40]
  #     idx = i * j
  #     vector += encodeURIComponent(tagdata[idx].name) + ';'

  #   console.log 'vector', vector

  #   request
  #     .get("http://api.stackexchange.com/tags/#{vector}/wikis?site=stackoverflow")
  #     .end (sres) =>

  #       batch = sres.body.items

  #       for d in batch

  #         update =
  #           name: d.tag_name
  #           short: d.tag_name
  #           soId: d.tag_name
  #           desc: d.excerpt

  #         console.log 'update', update

  #         return model.findOneAndUpdate soId: d.tag_name, update, { upsert: true }, (e, r) ->

# step 3 :: combine top 50 github repos
importTop50GithubProjects = (callback) ->
  $log 'importTop50GithubProjects'
  callback()

module.exports = ->

  importSkillsV0 -> importTop2000StackoverflowTags(importTop50GithubProjects)
