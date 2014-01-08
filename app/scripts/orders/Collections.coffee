exports = {}
BB = require './../../lib/BB'
Models = require './Models'

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: '/api/admin/orders'
  comparator: (m) ->
    -1 * moment(m.get('utc')).unix()
  _filter: (options) ->
    {timeString, sourceString} = options
    orders = @models

    if sourceString
      console.log 'sourceString', sourceString

      # TODO don't filter on utm; filter on marketing tags
      orders = _.filter orders, (o) ->
        utm = o.get('utm')
        if !utm || !utm.utm_source then return false
        # console.log sourceString, 'vs', utm.utm_source
        utm.utm_source.indexOf(sourceString) > -1

    if !timeString then return orders
    if 'all' == timeString then return orders

    now = moment()

    if 'tod' == timeString
      return _.filter orders, (m) ->
        0 == now.diff(moment(m.get('utc')), 'days');

    day = now.day()
    month = parseInt(options.month, 10) || now.month() # support current month button
    year = now.year()

    # if the month has not yet happened in this calendar year, use the previous
    # calendar year.
    if now.diff(moment().month(month))
      year -= 1

    return _.filter orders, (m) =>
      order = moment m.get('utc')
      order.year() == year && order.month() == month

module.exports = exports
