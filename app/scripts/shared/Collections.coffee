exports = {}
BB = require './../../lib/BB'
Models = require './Models'


class exports.Skills extends BB.FilteringCollection
  model: Models.Skill
  url: '/api/skills'
  comparator: (m) -> m.get 'name'


module.exports = exports