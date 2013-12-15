exports = {}
BB = require './../../lib/BB'
Models = require './Models'


class exports.Users extends BB.FilteringCollection
  model: Models.User
  url: '/api/admin/users'
  comparator: (m) -> m.get 'name'


class exports.Companys extends BB.FilteringCollection
  model: Models.Company
  url: '/api/admin/companys'
  comparator: (m) -> m.get 'id'



module.exports = exports
