exports = {}
BB      = require './../../lib/BB'
Models  = require './Models'

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: '/api/orders'
  comparator: (m) ->
    -1 * moment(m.get('utc')).unix()


class exports.Requests extends BB.FilteringCollection
  model: Models.Request
  url: '/api/requests'
  calls: ->
    c = []
    for m in @models
      {calls} = m.attributes
      if calls? && calls.length > 0
        for call in calls
          call.expert = (_.find m.get('suggested'), (o) ->
            o.expert._id == call.expertId).expert
          call.hasRecording = call.recordings? && call.recordings.length > 0
          c.push call
    c

module.exports = exports
