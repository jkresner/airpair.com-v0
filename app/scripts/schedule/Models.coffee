BB = require './../../lib/BB'
Shared = require './../shared/Models'

exports = {}

exports.Request = class Request extends Shared.Request
  urlRoot: '/api/requests'

exports.Order = Shared.Order

module.exports = exports
