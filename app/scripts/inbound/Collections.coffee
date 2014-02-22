exports = {}
BB      = require './../../lib/BB'
Models  = require './Models'
Shared  = require './../shared/Collections'

exports.Tags = Shared.Tags
exports.MarketingTags = Shared.MarketingTags

byName = (m) -> m.get 'name'
byRate = (m) -> (m.get 'rate') || 0

class exports.Experts extends BB.FilteringCollection
  model: Models.Expert
  url: '/api/experts'
  comparator: byName
  comparators:
    name: byName
    github: (m) -> -1 * (m.get('gh')?.followers || 0)
    stackoverflow: (m) -> -1 * (m.get('so')?.reputation || 0)
    low: byRate
    high: (m) -> -1 * byRate(m)
  _sort: ->
    _.sortBy @filteredModels, @comparator
  _filter: (f) ->
    # $log '_filter', f
    r  = @models
    if f?
      if f.searchTerm?
        pattern = new RegExp f.searchTerm, 'gi'
        r = _.filter r, (m) -> _.any ['name','username'], (attr) => pattern.test m.get attr
      if f.tag?
        r = _.filter r, (m) -> _.find(m.get('tags'), (t) -> t.short.toLowerCase() == f.tag.short.toLowerCase() )
      if f.excludes?
        for e in f.excludes
          exclude = _.find r, (m) -> m.get('_id') == e._id
          r = _.without r, exclude

    return r

class exports.Requests extends BB.FilteringCollection
  model: Models.Request
  url: '/api/admin/requests/active'
  comparator: (m) ->
    m.id # mongo id's sort by the date of their creation!
  _filter: (f) ->
    owner = f.filter.toLowerCase()
    r = @models
    if owner is 'all' then return r
    r = _.filter r, (m) =>
      m.get('owner') == owner || !m.get('owner')
    r
  _sort: ->
    # filteredModels are already sorted by time
    _.sortBy @filteredModels, (r) ->
      ordering =
        received:   0
        incomplete: 1
        holding:    2
        review:     3
        scheduled:  4
        completed:  5
        canceled:   6
      ordering[r.get('status')]

  prevNext: (id) ->
    ids = _.pluck(@filteredModels, 'id')
    curIndex = ids.indexOf id
    prev: ids[curIndex - 1], next: ids[curIndex + 1]

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: -> "/api/orders/request/#{@requestId}"

module.exports = exports
