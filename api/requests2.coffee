CRUDApi = require './_crud'
Skill = require './../models/skill'
Company = require './../models/company'
Dev = require './../models/dev'
und = require 'underscore'
async = require "async"

class RequestApi extends CRUDApi

  model: require './../models/request'

###############################################################################
## CRUD extensions
###############################################################################

  show: (req, res) =>
    @model.findOne { _id: req.params.id }, (e, r) =>
      # Company.findOne { _id: r.companyId }, (ee, rr) =>
      #   result = und.extend und.clone(r), { company: und.clone(rr) }
      #   console.log 'result', result
        # res.send result
      res.send r

  post: (req, res) =>
    req.body.events = [{ name:'created', utc: new Date()}]
    @getSkills req, =>
      @getDevs req, =>
        new @model( req.body ).save (er, re) -> res.send re

  update: (req, res) =>
    async.parallel [
      (callback) -> @getSkills req, callback
      (callback) -> @getDevs req, callback
    ], (error) ->
      return res.status(500).send error if error
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
        console.log 's.devsv', s.dev
        s.dev = und.find( r, (d) -> console.log 'd',d; d._id.toString() == s.dev._id )
      console.log 'req.body.suggested', req.body.suggested
      callback()


module.exports = new RequestApi()
