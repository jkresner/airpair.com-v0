async         = require 'async'
ObjectId      = require('mongoose').Types.ObjectId
DomainService = require './_svc'
Order         = require '../models/order'
Request       = require '../models/request'

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

    updateRequestAndOrders = (request, cb) =>
      mtags = request.marketingTags
      tag = _.find mtags, (t) -> t._id == tagId
      tag.name = savedTag.name
      tag.type = savedTag.type
      tag.group = savedTag.group
      tasks = [
        (done) => @copyToOrders request._id, mtags, request.owner, done
        (done) =>
          updates = $set: marketingTags: mtags
          Request.findByIdAndUpdate request._id, updates, done
      ]
      async.parallel tasks, cb

    sendSavedTag = (err, results) ->
      if err then return callback err
      callback null, savedTag

  # copy owner and marketingTags to every associated order.
  copyToOrders: (requestId, marketingTags, owner, callback) =>
    query = requestId: requestId
    updates = $set: { marketingTags: marketingTags, owner: owner || '' }
    Order.update query, updates, multi: true, callback
