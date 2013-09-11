DomainService   = require './_svc'

module.exports = class CompanysService extends DomainService

  model: require './../models/company'