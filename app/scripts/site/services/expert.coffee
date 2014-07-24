module.exports = (app) ->
  app.factory 'Expert', ($http, Restangular) ->
    Expert =
      fetchExpert: ->
        Restangular.one('experts', 'me').get().then (expert) =>
          @private.data.expert = expert
          @private.fetchExpertRequests(expert._id)
          @private.fetchExpertOrders(expert._id)

      hoursAvailable: (value) ->
        if value?
          Expert.private.data.expert.hours = value.toString()
        Expert.private.data.expert? && Expert.private.data.expert.hours

      status: (value) ->
        if value?
          Expert.private.data.expert.status = if value then "ready" else "busy"
        Expert.private.data.expert? && Expert.private.data.expert.status == "ready"

      availability: (value) ->
        if value?
          Expert.private.data.expert.availability = value
        Expert.private.data.expert? && Expert.private.data.expert.availability

      requestStats: ->
        responseRate: @private.responseRate()
        requestCount: @private.requestCount()

      orderStats: ->
        paidOrderCount: @private.paidOrders().length
        totalAmountReceived: @private.totalAmountReceived()
        averagePerHour: @private.averagePerHour()

      update: ->
        console.log "updating expert"
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


    Expert.fetchExpert()
    Expert
