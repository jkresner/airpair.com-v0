exports = {}
BB      = require './../../lib/BB'
Models  = require './Models'
Shared  = require './../shared/Collections'

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: -> "/api/orders/request/#{@requestId}"

class exports.Videos extends BB.FilteringCollection
  model: Models.Video
  getByYoutubeId: (youtubeId) ->
    _.find @models, (m) -> m.get('data').id == youtubeId

class exports.RequestCalls extends BB.FilteringCollection
  model: Models.RequestCall
  url: -> "/api/requests/calls/list"
  comparator: (m) -> -1 * (new Date m.get('datetime')).getTime()

exports.Requests = Shared.Requests

module.exports = exports
