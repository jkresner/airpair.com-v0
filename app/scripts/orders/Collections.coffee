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

    now = moment().local()

    if 'tod' == timeString
      return _.filter orders, (m) ->
        moment(m.get('utc')).local().isSame(now, 'day')

    if 'wk' == timeString
      lastSaturday = now.day(-1).hour(0).minute(0).second(0).millisecond(0)
      return _.filter orders, (m) ->
        moment(m.get('utc')).local().isAfter(lastSaturday)

    day = now.day()
    # support current month button
    month = parseInt(options.month, 10) || now.month()
    year = now.year()

    # if the month has not yet happened in this calendar year, use the previous
    # calendar year.
    if now.diff(moment().month(month))
      year -= 1

    return _.filter orders, (m) =>
      order = moment m.get('utc')
      order.year() == year && order.month() == month

module.exports = exports
