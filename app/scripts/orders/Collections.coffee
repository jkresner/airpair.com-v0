exports = {}
BB = require './../../lib/BB'
Models = require './Models'

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: '/api/admin/orders'
  comparator: (m) ->
    -1 * new moment(m.get('utc')).unix()
  _filter: (f) ->
    # $log 'f', f
    fltr = f.filter
    now = new moment()
    n = { yr: now.year(), mth: now.month(), day: now.day() }
    if f.mth? then n.mth = parseInt f.mth

    r = @models
    # $log 'now', now, now.year(), now.month()
    if fltr is 'all' then return r
    else if fltr is 'tod'
      r = _.filter r, (m) =>
        0 == now.diff(new moment(m.get('utc')), 'days');
    else
      # $log 'n.mth', n.mth
      r = _.filter r, (m) =>
        mom = new moment m.get('utc')
        mom.year() == n.yr && mom.month() == n.mth

    return r

module.exports = exports