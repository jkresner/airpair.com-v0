DomainService = require './_svc'

module.exports = class SourcesService extends DomainService
  model: require './../models/source'
