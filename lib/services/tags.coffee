DomainService   = require './_svc'

module.exports = class TagsService extends DomainService

  model: require './../models/tag'