exports = {}
BB = require './../../lib/BB'
Models = require './Models'
Shared = require './../shared/Collections'


exports.Tags = Shared.Tags

class exports.Experts extends BB.FilteringCollection
  model: Models.Expert
  url: '/api/experts'
  comparator: (m) -> m.get 'name'
  _filter: (f) ->
    $log '_filter', f
    r  = @models
    if f?
      if f.tag?
        r = _.filter r, (m) -> _.find(m.get('tags'), (t) -> t.name == f.tag.name )
    return r


class exports.Requests extends BB.FilteringCollection
  model: Models.Request
  url: '/api/admin/requests'
  comparator: (m) -> m.get('events')[0].utc


module.exports = exports