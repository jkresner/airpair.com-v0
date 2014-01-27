BB = require './../../lib/BB'
Shared = require './../shared/Models'

exports = {}

exports.Request = class Request extends Shared.Request
  urlRoot: '/api/requests'

exports.RequestCall = class RequestCall extends BB.BadassModel
  urlRoot: ->
    "/api/requests/#{@requestId}/calls"

exports.Order = Shared.Order

module.exports = exports
