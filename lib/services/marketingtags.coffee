async         = require 'async'
ObjectId      = require('mongoose').Types.ObjectId
DomainService = require './_svc'
Order         = require '../models/order'
Request       = require '../models/request'

module.exports = class MarketingTagsService extends DomainService

  model: require '../models/marketingtag'

  update: (tagId, tag, callback) =>
    {name,type,group} = tag

    updateRequestAndOrders = (request, cb) =>
      r = request
      tag = _.find r.marketingTags, (t) -> t._id == tagId
      tag.name = name
      tag.type = type
      tag.group = group
      tasks = [
        (done) => @copyToOrders r._id, r.marketingTags, r.owner, done
        (done) => Request.findByIdAndUpdate r._id, $set: marketingTags: r.marketingTags, done
      ]
      async.parallel tasks, cb

    super tagId, tag, (e, t) =>
      query = marketingTags: $elemMatch: _id: tagId
      select = _id: 1, marketingTags: 1, owner: 1
      Request.find query, select, lean: true, (ee, requests) =>
        async.map requests, updateRequestAndOrders, callback


  # copy owner and marketingTags to every associated order.
  copyToOrders: (requestId, marketingTags, owner, callback) =>
    query = requestId: requestId
    updates = $set: { marketingTags: marketingTags, owner: owner || '' }
    Order.update query, updates, multi: true, callback
