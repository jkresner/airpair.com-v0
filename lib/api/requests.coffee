CRUDApi = require './_crud'
Skill = require './../models/skill'
Company = require './../models/company'
Dev = require './../models/dev'
und = require 'underscore'

class RequestApi extends CRUDApi

  model: require './../models/request'

###############################################################################
## CRUD extensions
###############################################################################

  list: (req, res) =>
    search = userId: req.user._id
    @model.find search, (e, r) ->
      r = {} if r is null
      res.send r

  detail: (req, res) =>

    @model.findOne { _id: req.params.id }, (e, r) =>
      # Company.findOne { _id: r.companyId }, (ee, rr) =>
      #   result = und.extend und.clone(r), { company: und.clone(rr) }
      #   console.log 'result', result
        # res.send result
      res.send r

  create: (req, res) =>
    req.body.userId = req.user._id
    req.body.events = [{ name:'created', utc: @utcNow()}]
    req.body.status = 'received'

    @getDevs req, =>
      new @model( req.body ).save (e, r) ->
        # $log 'created.', r.company.contacts
        # $log 'created', re
        res.send r

  update: (req, res) =>
    @getDevs req, =>
      data = und.clone req.body
      delete data._id # so mongo doesn't complain
      @model.update { _id: req.params.id }, data, (e, r) -> res.send req.body

  getDevs: (req, callback) =>
    if ! req.body.suggested? then return callback()

    devs = und.pluck req.body.suggested, 'dev'
    devIds = und.pluck devs, '_id'
    Dev.find().where('_id').in(devIds).exec (er, re) =>
      console.log 're', re,
      console.log 'req.body.suggested', req.body.suggested
      for s in req.body.suggested
        console.log 's.devsv', s.dev
        s.dev = und.find( re, (d) -> console.log 'd',d; d._id.toString() == s.dev._id )
      console.log 'req.body.suggested', req.body.suggested
      callback()


module.exports = (app) -> new RequestApi app,'requests'