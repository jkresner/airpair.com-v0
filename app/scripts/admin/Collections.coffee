exports = {}
BB = require './../../lib/BB'
Models = require './Models'


class exports.Leads extends BB.FilteringCollection
  model: Models.Lead
  url: '/api/leads'


class exports.Skills extends BB.FilteringCollection
  model: Models.Skill
  url: '/api/skills'
  comparator: (m) -> m.get 'name'


class exports.Devs extends BB.FilteringCollection
  model: Models.Dev
  url: '/api/devs'
  comparator: (m) -> m.get 'name'


module.exports = exports