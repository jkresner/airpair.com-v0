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
        console.log 'new req', req.body.events
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
      for s in req.body.suggested
        devId = s.dev._id
        updatedDev = und.find r, (d) -> d._id = devId
        s.dev = updatedDev
      console.log 'suggested', req.body.suggested
      callback()


module.exports = new DevApi()