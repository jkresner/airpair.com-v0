Expert = ($http, $rootScope, Restangular) ->
  expertObject =
    fetchExpert: ->
      Restangular.one('experts', 'me').get().then (expert) =>
        @private.data.expert = expert
        $rootScope.$emit('expertLoaded')
        @private.initializeTags()
        @private.fetchExpertRequests(expert._id)
        @private.fetchExpertOrders(expert._id)

    hoursAvailable: (value) ->
      if value?
        expertObject.private.data.expert.hours = value.toString()
      expertObject.private.data.expert? && expertObject.private.data.expert.hours

    status: (value) ->
      if value?
        expertObject.private.data.expert.status = if value then "ready" else "busy"
      expertObject.private.data.expert? && expertObject.private.data.expert.status == "ready"

    setRate: (min, max) ->
      @minRate(min)
      @rate(max)

    rate: (value) ->
      if value?
        expertObject.private.data.expert.rate = value
      expertObject.private.data.expert? && expertObject.private.data.expert.rate

    minRate: (value) ->
      if value?
        expertObject.private.data.expert.minRate = value
      expertObject.private.data.expert? && expertObject.private.data.expert.minRate

    tags: ->
      expertObject.private.data.expert? && expertObject.private.data.expert.tags

    tagHasLevel: (tag, level) ->
      _.include(tag.levels, level)

    availability: (value) ->
      if value?
        expertObject.private.data.expert.availability = value
      expertObject.private.data.expert? && expertObject.private.data.expert.availability

    requestStats: ->
      responseRate: @private.responseRate()
      requestCount: @private.requestCount()

    orderStats: ->
      paidOrderCount: @private.paidOrders().length
      totalAmountReceived: @private.totalAmountReceived()
      averagePerHour: @private.averagePerHour()

    update: ->
      @private.data.expert.save()

    private:
      data: {}

      expertId: ->
        @data.expert? && @data.expert._id

      requests: ->
        @data.requests || []

      orders: ->
        @data.orders || []

      fetchExpertRequests: ->
        Restangular.all("requests/expert/#{@expertId()}").getList().then (requests) =>
          @data.requests = requests

      fetchExpertOrders: ->
        Restangular.all("orders/expert/#{@expertId()}").getList().then (orders) =>
          @data.orders = orders

      requestCount: -> @requests().length

      responseRate: ->
        if @requestCount() > 0
          (@respondedCount() / @requestCount()) * 100
        else
          0

      respondedCount: ->
        _.select(@suggestions(), (suggestion) ->
          suggestion.expertStatus not in ["waiting", "opened"]
        ).length

      suggestions: ->
        expertId = @expertId()
        _.map @requests(), (request) =>
           _.find request.suggested, (suggestion) ->
             suggestion.expert._id == expertId

      paidOrders: ->
        _.select @orders(), (order) ->
          order.payment? && order.payment.paid

      averagePerHour: ->
        if @orderHours() > 0
          @totalAmountReceived() / @orderHours()
        else
          0

      orderHours: ->
        _.reduce(@paidOrders(), (sum, order) ->
          itemSum = _.reduce(order.lineItems, (sum2, lineItem) ->
            sum2 + lineItem.qty
          , 0)
          sum + itemSum
        , 0)

      totalAmountReceived: ->
        _.reduce(@paidOrders(), (sum, order) ->
          sum + order.total - order.profit
        , 0)

      initializeTags: ->
        _.each @data.expert.tags, (tag) =>
          tag.levelBeginner = @tagGetterSetter(tag, 'beginner')
          tag.levelIntermediate = @tagGetterSetter(tag, 'intermediate')
          tag.levelexpertObject = @tagGetterSetter(tag, 'expert')

      tagGetterSetter: (tag, level) ->
        (value) ->
          if value?
            if value
              _.include(tag.levels, level) || tag.levels.push(level)
            else
              tag.levels = _.without(tag.levels, level)
          else
            _.include(tag.levels, level)



  expertObject.fetchExpert()
  expertObject

angular
  .module('ngAirPair')
  .factory('Expert', ['$http', '$rootScope', 'Restangular', Expert])
