module.exports = (app) ->
  app.factory 'Expert', ($http) ->
    Expert =
      fetchExpert: ->
        $http.get("/api/experts/me")
          .success (data) =>
            @private.data.expert = data
            @private.fetchExpertRequests(data._id)
            @private.fetchExpertOrders(data._id)
          .error (data) ->
            console.log('Error: ' + data)

      hoursAvailable: ->
          @private.data.expert? && @private.data.expert.hours

      requestStats: ->
        responseRate: @private.responseRate()
        requestCount: @private.requestCount()

      orderStats: ->
        paidOrderCount: @private.paidOrders().length
        totalAmountReceived: @private.totalAmountReceived()
        averagePerHour: @private.averagePerHour()

      private:
        data: {}

        expertId: ->
          @data.expert? && @data.expert._id

        requests: ->
          @data.requests || []

        orders: ->
          @data.orders || []

        fetchExpertRequests: ->
          $http.get("/api/requests/expert/#{@expertId()}")
            .success (data) =>
              @data.requests = data
            .error (data) ->
              console.error('Error: ' + data)

        fetchExpertOrders: ->
          $http.get("/api/orders/expert/#{@expertId()}")
            .success (data) =>
              @data.orders = data
            .error (data) ->
              console.error('Error: ' + data)

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
