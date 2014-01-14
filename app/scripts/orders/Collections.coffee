exports = {}
BB = require './../../lib/BB'
Models = require './Models'

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: '/api/admin/orders'
  comparator: (m) ->
    -1 * moment(m.get('utc')).unix()
  _filter: (options) ->
    {timeString, marketingTags} = options
    orders = @models

    if marketingTags && marketingTags.length
      console.log '===marketingTags', marketingTags, '==='
      desiredIds = marketingTags.map (t) -> t._id

      orders = _.filter orders, (o) ->
        orderTags = o.get('marketingTags') || []
        if !orderTags.length then return false

        ids = orderTags.map (t) -> t._id
        for desired in desiredIds
          contained = ids.indexOf desired > -1
          if !contained then return false
        true

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
