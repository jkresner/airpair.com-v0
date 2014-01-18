BB = require './../../lib/BB'
Shared = require './../shared/Models'

exports = {}

exports.Request = class Request extends Shared.Request
  urlRoot: '/api/requests'
  # initialize: (args) ->
  #   @callId = args.callId

exports.RequestCall = class RequestCall extends BB.BadassModel
  urlRoot: ->
    "/api/requests/#{@requestId}/calls"

exports.Order = Shared.Order

module.exports = exports
