CRUDApi = require './_crud'
Skill = require './../models/skill'
Dev = require './../models/dev'
und = require 'underscore'

class DevApi extends CRUDApi

  model: require './../models/request'

###############################################################################
## CRUD extensions
###############################################################################

  post: (req, res) =>
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
    Skill.find().where('soId').in(skillsSoIds).select('_id soId').exec (e, r) =>
      req.body.skills = r
      callback()

  getDevs: (req, callback) =>
    devs = und.pluck req.body.suggested.split(","), 'dev'
    devIds = und.pluck devs, 'id'
    Dev.find().where('_id').in(devIds).exec (e, r) =>
      for s in req.body.suggested
        devId = s.dev._id
        updatedDev = und.find devs, (d) -> d._id = devId
        s.dev = updatedDev
      callback()


module.exports = new DevApi()