Skill = require './../models/skill'

exports.clear = -> Skill.find({}).remove()
exports.boot = (callback) ->
  stubs = require './../app/stubs/skills'
  skills = []
  skills.push name: s.name, shortName: s.shortName, soId: s.soId for s in stubs
  Skill.create skills, (e, r) -> if callback? then callback()


exports.post = (req, res) ->
  new Skill( req.body ).save( (err, result) -> res.send result )


exports.list = (req, res) ->
  Skill.find( (err, list) -> res.send list )


exports.show = (req, res) ->
  Skill.findOne { _id: req.params.id }, (error, item) ->
    res.send item