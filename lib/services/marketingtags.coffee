DomainService = require './_svc'

module.exports = class MarketingTagsService extends DomainService
  model: require '../models/marketingtag'

  edit: (changedTag, cb) ->
    ###
    find the tag in the DB, update it
    find all requests with this tag, update em
    find all orders with this tag, update em
    ###

    @update changedTag._id, changedTag, cb
