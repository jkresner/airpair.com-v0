exports = {}
BB      = require 'BB'
Models  = require './Models'


class exports.Users extends BB.FilteringCollection
  model: Models.User
  url: '/api/admin/users'
  comparator: (m) -> m.get 'name'


class exports.Companys extends BB.FilteringCollection
  model: Models.Company
  url: '/api/admin/companys'
  comparator: (m) -> m.get 'id'



class exports.PayMethods extends BB.FilteringCollection
  model: Models.PayMethod
  url: '/api/paymethods'



module.exports = exports
