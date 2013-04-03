CRUDApi = require './_crud'
Skill = require './../models/skill'
und = require 'underscore'

class DevApi extends CRUDApi

  model: require './../models/dev'

###############################################################################
## CRUD extensions
###############################################################################

  post: (req, res) =>
    @getSkills req, =>
      new @model( req.body ).save (er, re) -> res.send re

  update: (req, res) =>
    @getSkills req, =>
      data = und.clone req.body
      delete data._id # so mongo doesn't complain
      @model.update { _id: req.params.id }, data, (e, r) -> res.send req.body

  getSkills: (req, callback) =>
    skillsSoIds = req.body.skills.split(",")
    Skill.find().where('soId').in(skillsSoIds).select('_id soId').exec (e, r) =>
      req.body.skills = r
      callback()



module.exports = new DevApi()