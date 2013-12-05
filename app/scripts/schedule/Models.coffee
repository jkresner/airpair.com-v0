BB = require './../../lib/BB'
Shared = require './../shared/Models'
# <<<<<<< Updated upstream

# exports = {}

# exports.Request = Shared.Request

# exports.Order = Shared.Order

# =======
exports = {}

exports.Request = class Request extends Shared.Request
  urlRoot: '/api/requests'

module.exports = exports
