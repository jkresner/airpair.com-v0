exports = {}
BB      = require 'BB'
Models  = require './Models'
Shared  = require './../shared/Collections'

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: -> "/api/orders/request/#{@requestId}"

class exports.Videos extends BB.FilteringCollection
  model: Models.Video
  getByYoutubeId: (youtubeId) ->
    _.find @models, (m) -> m.get('data').id == youtubeId

exports.Requests = Shared.Requests

module.exports = exports
