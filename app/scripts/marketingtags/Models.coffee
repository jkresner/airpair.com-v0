BB      = require 'BB'
Shared  = require './../shared/Models'
exports = {}

class exports.MarketingTag extends BB.BadassModel
  urlRoot: '/api/marketingtags'

module.exports = exports
