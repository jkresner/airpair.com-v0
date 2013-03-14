Skill = require '../models/skill'

exports.clear = -> Skill.find({}).remove()
exports.boot = ->
  stubs = require './../app/stubs/skills'
  new Skill( name: s.name, shortName: s.shortName, soId: s.soId ).save() for s in stubs


exports.post = (req, res) ->
  new Skill( req.body ).save( (err, result) -> res.send result )


exports.list = (req, res) ->
  Skill.find( (err, list) -> res.send list )


exports.show = (req, res) ->
  Skill.findOne { _id: req.params.id }, (error, item) ->
    res.send item