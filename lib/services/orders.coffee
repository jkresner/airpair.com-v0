DomainService   = require './_svc'

module.exports = class OrdersService extends DomainService

  model: require './../models/order'