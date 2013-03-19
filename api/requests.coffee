CRUDApi = require './_crud'
Skill = require './../models/skill'
Dev = require './../models/dev'
und = require 'underscore'

class DevApi extends CRUDApi

  model: require './../models/request'

###############################################################################
## Data loading (should be removed soon)
###############################################################################

  clear: -> @model.find({}).remove()

###############################################################################
## CRUD extensions
###############################################################################

  post: (req, res) =>
    req.body.events = [{ name:'created', utc: new Date()}]
    @getSkills req, =>
      @getDevs req, =>
        new @model( req.body ).save (er, re) -> res.send re

  update: (req, res) =>
    @getSkills req, =>
      @getDevs req, =>
        data = und.clone req.body
        delete data._id # so mongo doesn't complain
        @model.update { _id: req.params.id }, data, (e, r) -> res.send req.body

  getSkills: (req, callback) =>
    skillsSoIds = req.body.skills.split(",")
    Skill.find().where('soId').in(skillsSoIds).exec (e, r) =>
      req.body.skills = r
      callback()

  getDevs: (req, callback) =>
    devs = und.pluck req.body.suggested, 'dev'
    devIds = und.pluck devs, '_id'
    Dev.find().where('_id').in(devIds).exec (e, r) =>
      console.log 'r', r,
      console.log 'req.body.suggested', req.body.suggested
      for s in req.body.suggested
        console.log 's.dev', s.dev
        s.dev = und.find( r, (d) -> console.log 'd',d; d._id.toString() == s.dev._id )
      console.log 'req.body.suggested', req.body.suggested
      callback()


module.exports = new DevApi()