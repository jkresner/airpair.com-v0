und = require 'underscore'
Tag = require './../models/tag'
v0_skillsdata = require './data/v0.3/skills'
stackoverflow_tagWikisdata = require './data/stackoverflow/wikis'

migrateFromSkill = (s) ->
  _id: s._id
  name: s.name
  short: s.shortName
  soId: s.soId


migrateFromStack = (t) ->
  match = und.find v0_skillsdata, (s) -> s.soId == t.tag_name

  if match?
    update = desc: t.excerpt
  else
    update =
      name: t.tag_name
      short: t.tag_name
      soId: t.tag_name
      desc: t.excerpt

# step 1 :: load in skills from v0 (to maintain original ids)
importSkillsV0 = (callback) ->
  count = 0
  for s in v0_skillsdata
    new Tag( migrateFromSkill(s) ).save (e, r) =>
      if e? then $log "added.tag[#{count}]", e, r
      count++
      if count == v0_skillsdata.length then callback()


# step 2 :: run stack exchange import (findOneAndUpdate)
importTop2000StackoverflowTags = (callback) ->
  count = 0
  $log 'importTop2000StackoverflowTags!!'
  pageSize = 20

  for i in [0...stackoverflow_tagWikisdata.length]
    t = stackoverflow_tagWikisdata[i]
    search = soId: t.tag_name

    Tag.findOneAndUpdate search, migrateFromStack(t), { upsert: true }, (e, r) ->
      if e? then $log "[added #{count}] #{r.name} #{r.desc}"
      count++
      if count == stackoverflow_tagWikisdata.length then callback()


# step 3 :: combine top 50 github repos
importTop50GithubProjects = (callback) ->
  $log 'importTop50GithubProjects'


module.exports = (callback) ->
  Tag.find({}).remove ->
    $log 't[0] tags removed'
    Tag.collection.dropAllIndexes (e, r) ->
      $log "t[1] adding #{v0_skillsdata.length} v0_skillsdata"
      importSkillsV0 ->
        $log "t[2] adding #{stackoverflow_tagWikisdata.length} stackoverflow_tagWikisdata"
        importTop2000StackoverflowTags ->
          "t[3] finding all Tags"
          Tag.find {}, (e, r) ->
            "t[4] saved r.length tags"
            callback r
          # importTop50GithubProjects ->