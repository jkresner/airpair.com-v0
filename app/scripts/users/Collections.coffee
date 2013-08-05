exports = {}
BB = require './../../lib/BB'
Models = require './Models'

class exports.Users extends BB.FilteringCollection
  model: Models.User
  url: '/api/admin/users'
  comparator: (m) -> m.get 'name'


module.exports = exports
