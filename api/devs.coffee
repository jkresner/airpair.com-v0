_und = require './../vendor/scripts/lodash'

# /* The API controller
#    Exports 3 methods:
#    * post - Creates a new thread
#    * list - Returns a list of threads
#    * show - Displays a thread and its posts
# */
Dev = require '../models/dev'
Skill = require '../models/skill'

insertFromStub = (s) ->
  skillsSoIds = _und.pluck(s.skills,'soId')
  Skill.find().where('soId').in(skillsSoIds).select('_id soId').exec (err, skills) ->
    d = name: s.name, email: s.email, pic: s.pic, homepage: s.homepage, gh: s.gh, so: s.so, other: s.other, skills: skills, rate: 0
    #console.log 'dev.new', d
    Dev.create d, (e, r) -> {}



exports.clear = -> Dev.find({}).remove()
exports.boot = () ->
  stubs = require './../app/stubs/devs'
  insertFromStub(s) for s in stubs


exports.post = (req, res) ->
  skillsSoIds = req.body.skills.split(",")
  console.log 'skillsSoIds', skillsSoIds
  Skill.find().where('soId').in(skillsSoIds).select('_id soId').exec (err, skills) ->
    req.body.skills = skills
    console.log 'skills', req.body.skills
    new Dev( req.body ).save( (err, result) -> res.send result )

exports.list = (req, res) ->
  Dev.find( (err, list) -> res.send list )


exports.show = (req, res) ->
  Dev.findOne { name: req.params.name }, (error, item) ->
    res.send item