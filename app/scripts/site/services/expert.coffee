ngExpert = ($http, $rootScope, Restangular) ->
  class Expert

    data = {}

    expertId = ->
      data.expert? && data.expert._id

    requests = ->
      data.requests || []

    orders = ->
      data.orders || []

    fetchExpertRequests = ->
      Restangular.all("requests/expert/#{expertId()}").getList().then (requests) =>
        data.requests = requests

    fetchExpertOrders = ->
      Restangular.all("orders/expert/#{expertId()}").getList().then (orders) =>
        data.orders = orders

    requestCount = -> requests().length

    suggestions = ->
      _.map requests(), (request) =>
         _.find request.suggested, (suggestion) ->
           suggestion.expert._id == expertId()

    respondedCount = ->
      _.select(suggestions(), (suggestion) ->
        suggestion.expertStatus not in ["waiting", "opened"]
      ).length

    responseRate = ->
      if requestCount() > 0
        (respondedCount() / requestCount()) * 100
      else
        0

    paidOrders = ->
      _.select orders(), (order) ->
        order.payment? && order.payment.paid

    totalAmountReceived = ->
      _.reduce(paidOrders(), (sum, order) ->
        sum + order.total - order.profit
      , 0)

    orderHours = ->
      _.reduce(paidOrders(), (sum, order) ->
        itemSum = _.reduce(order.lineItems, (sum2, lineItem) ->
          sum2 + lineItem.qty
        , 0)
        sum + itemSum
      , 0)

    averagePerHour = ->
      if orderHours() > 0
        totalAmountReceived() / orderHours()
      else
        0

    initializeTags = ->
      _.each data.expert.tags, (tag) =>
        tag.levelBeginner = tagGetterSetter(tag, 'beginner')
        tag.levelIntermediate = tagGetterSetter(tag, 'intermediate')
        tag.levelExpert = tagGetterSetter(tag, 'expert')
        tag.levelAny = ->
          tag.levelBeginner() || tag.levelIntermediate() || tag.levelExpert()

    tagGetterSetter = (tag, level) ->
      (value) ->
        if value?
          if value
            _.include(tag.levels, level) || tag.levels.push(level)
          else
            tag.levels = _.without(tag.levels, level)
        else
          _.include(tag.levels, level)

    constructor:  ->
      @fetchExpert()

    fetchExpert: ->
      Restangular.one('experts', 'me').get().then (expert) =>
        data.expert = expert
        initializeTags()
        fetchExpertRequests(expert._id)
        fetchExpertOrders(expert._id)

    hoursAvailable: (value) ->
      if value?
        data.expert.hours = value.toString()
      data.expert? && data.expert.hours

    busyUntil: (value) ->
      if value?
        data.expert.busyUntil = value
      # horrible hack, but angular blows up if you return
      # a date object from a getter and the angular date
      # input requires a date object #itsabug
      data.expert? && $('#busyUntil').val(moment(data.expert.busyUntil).format("YYYY-MM-DD"))
      data.expert? && moment(data.expert.busyUntil).format()

    status: (value) ->
      if value?
        data.expert.status = if value then "ready" else "busy"
        data.expert.availability = ""
      data.expert? && data.expert.status == "ready"

    setRate: (min, max) ->
      @minRate(min)
      @rate(max)

    rate: (value) ->
      if value?
        data.expert.rate = value
      data.expert? && data.expert.rate

    minRate: (value) ->
      if value?
        data.expert.minRate = value
      data.expert? && data.expert.minRate

    tags: ->
      data.expert? && data.expert.tags

    tagHasLevel: (tag, level) ->
      _.include(tag.levels, level)

    availability: (value) ->
      if value?
        data.expert.availability = value
      data.expert? && data.expert.availability

    requestStats: ->
      responseRate: responseRate()
      requestCount: requestCount()

    orderStats: ->
      paidOrderCount: paidOrders().length
      totalAmountReceived: totalAmountReceived()
      averagePerHour: averagePerHour()

    update: ->
      data.expert.save()

  new Expert

angular
  .module('ngAirPair')
  .factory('Expert', ['$http', '$rootScope', 'Restangular', ngExpert])
