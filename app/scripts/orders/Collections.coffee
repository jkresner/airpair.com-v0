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
      orders = _.filter orders, (o) ->
        orderTags = o.get('marketingTags') || []
        if !orderTags.length then return false

        # every marketing tag should be contained in the order's tag list
        _.every marketingTags, (desired) ->
          _.some orderTags, (ot) ->
            desired._id == ot._id

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
