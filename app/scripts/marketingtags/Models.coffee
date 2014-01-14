BB = require './../../lib/BB'
Shared = require './../shared/Models'
exports = {}

class exports.MarketingTag extends BB.BadassModel
  urlRoot: '/api/marketingtags'

exports.Request = Shared.Request
module.exports = exports
