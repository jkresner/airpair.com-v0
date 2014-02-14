async         = require 'async'
DomainService = require './_svc'
oSvc          = new (require './orders')()
Request       = require '../models/request'
ObjectId      = require('mongoose').Types.ObjectId

setMarketingTagsOnOrders = require '../util/setMarketingTagsOnOrders'

module.exports = class MarketingTagsService extends DomainService
  model: require '../models/marketingtag'

  edit: (changedTag, callback) =>
    tagId = changedTag._id
    delete changedTag._id

    savedTag = null
    options = 'new': true, lean: true
    @model.findByIdAndUpdate tagId, changedTag, options, (err, tag) =>
      if err then return callback err
      savedTag = tag
      query = marketingTags: $elemMatch: _id: tagId
      select = _id: 1, marketingTags: 1, owner: 1
      Request.find query, select, lean: true, (err, requests) =>
        async.map requests, updateRequestAndOrders, sendSavedTag

    updateRequestAndOrders = (request, cb) ->
      mtags = request.marketingTags
      tag = _.find mtags, (t) -> t._id == tagId
      tag.name = savedTag.name
      tag.type = savedTag.type
      tag.group = savedTag.group
      tasks = [
        (done) ->
          updates = $set: marketingTags: mtags
          Request.findByIdAndUpdate request._id, updates, done

        (done) ->
          setMarketingTagsOnOrders request._id, mtags, request.owner, done
      ]
      async.parallel tasks, cb

    sendSavedTag = (err, results) ->
      if err then return callback err
      callback null, savedTag
