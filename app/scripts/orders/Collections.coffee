exports = {}
BB      = require './../../lib/BB'
Models  = require './Models'

LAST_SATURDAY = -1
SATURDAY = 6

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

    # shows orders since last saturday.
    # if today is saturday, it only shows orders from today.
    if 'wk' == timeString
      if now.day() == SATURDAY
        saturday = now.clone()
      else
        saturday = now.clone().day(LAST_SATURDAY)
      saturday = saturday.hour(0).minute(0).second(0).millisecond(0)
      return _.filter orders, (m) ->
        moment(m.get('utc')).local().isAfter(saturday)

    day = now.day()
    # support current month button
    options.month = parseInt(options.month, 10)
    if isFinite(options.month)
      month = options.month
    else
      month = now.month()
    year = now.year()

    # if the month has not yet happened in this calendar year, use the previous
    # calendar year.
    nowMonth = moment().month(now.month())
    if nowMonth.diff(moment().month(month)) < 0
      year -= 1

    return _.filter orders, (m) =>
      order = moment m.get('utc')
      order.year() == year && order.month() == month

module.exports = exports
