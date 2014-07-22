module.exports = (app) ->
  app.controller 'ExpertSettingsController',
    ($scope, $http, $window, Session, $log) ->
      _.extend $scope,
        name: "expertsController"

        fetchExpert: ->
          $http.get("/api/experts/me")
            .success (data) ->
              $scope.expert = data
              $scope.fetchExpertRequests(data._id)
              $scope.fetchExpertOrders(data._id)
            .error (data) ->
              console.log('Error: ' + data)

        fetchExpertRequests: (expertId) ->
          $http.get("/api/requests/expert/#{expertId}")
            .success (data) =>
              $scope.expertRequests = data
              $scope.expertRequestStats = @buildRequestStats(expertId, data)
            .error (data) ->
              console.error('Error: ' + data)

        fetchExpertOrders: (expertId) ->
          $http.get("/api/orders/expert/#{expertId}")
            .success (data) =>
              $scope.expertOrders = data
              $scope.expertOrderStats = @buildOrderStats(expertId, data)
            .error (data) ->
              console.error('Error: ' + data)

        buildRequestStats: (expertId, requests) ->
          requestCount: ->
            requests.length

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
            _.map requests, (request) ->
               _.find(request.suggested, (suggestion) -> suggestion.expert._id == expertId)

        buildOrderStats: (expertId, orders) ->
          paidOrders: ->
            _.select orders, (order) ->
              order.payment? && order.payment.paid

          paidOrderCount: ->
            @paidOrders().length

          totalAmountReceived: ->
            _.reduce(@paidOrders(), (sum, order) ->
              sum + order.total - order.profit
            , 0)


      $scope.fetchExpert()
