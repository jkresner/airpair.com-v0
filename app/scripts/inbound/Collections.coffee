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
    # $log '_filter', f
    r  = @models
    if f?
      if f.searchTerm?
        pattern = new RegExp f.searchTerm, 'gi'
        r = _.filter r, (m) -> _.any ['name','username'], (attr) => pattern.test m.get attr
      if f.tag?
        r = _.filter r, (m) -> _.find(m.get('tags'), (t) -> t.name == f.tag.name )
      if f.excludes?
        for e in f.excludes
          exclude = _.find r, (m) -> m.get('_id') == e._id
          r = _.without r, exclude

    return r

class exports.Requests extends BB.FilteringCollection
  model: Models.Request
  url: '/api/admin/requests'
  comparator: (m) -> m.get('events')[0].utc
  _filter: (f) ->
    owner = f.filter.toLowerCase()
    r = @models
    if owner is 'all' then return r
    r = _.filter r, (m) =>
      m.get('owner') == owner
    console.log r
    r

module.exports = exports
