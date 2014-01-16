DomainService = require './_svc'

module.exports = class MarketingTagsService extends DomainService
  model: require './../models/MarketingTag'
