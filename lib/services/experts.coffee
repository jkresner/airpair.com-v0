DomainService   = require './_svc'

module.exports = class ExpertsService extends DomainService

  model: require './../models/expert'