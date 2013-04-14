exports = {}
BB = require './../../lib/BB'
Models = require './Models'


class exports.Requests extends BB.FilteringCollection
  model: Models.Request
  url: '/api/requests'


class exports.Skills extends BB.FilteringCollection
  model: Models.Skill
  url: '/api/skills'
  comparator: (m) -> m.get 'name'


class exports.Devs extends BB.FilteringCollection
  model: Models.Dev
  url: '/api/devs'
  comparator: (m) -> m.get 'name'


class exports.Companys extends BB.FilteringCollection
  model: Models.Company
  url: '/api/companys'
  comparator: (m) -> m.get 'name'





module.exports = exports