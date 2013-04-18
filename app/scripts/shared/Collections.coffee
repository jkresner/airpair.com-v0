exports = {}
BB = require './../../lib/BB'
Models = require './Models'


und.extend exports, require './../tags/Collections'


class exports.Skills extends BB.FilteringCollection
  model: Models.Skill
  url: '/api/skills'
  comparator: (m) -> m.get 'name'


module.exports = exports