DomainService = require './_svc'

module.exports = class UsersService extends DomainService

  model: require '../models/user'

