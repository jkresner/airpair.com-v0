module.exports = (app) ->
  app.controller 'ExpertSettingsController',
    ($scope, $http, $window, Session) ->
      _.extend $scope,
        name: "expertsController"

        updateExpert: ->
          $http.get("/api/experts/me")
            .success (data) ->
              $scope.expert = data
              $scope.updateExpertRequests(data._id)
            .error (data) ->
              console.log('Error: ' + data)

        updateExpertRequests: (expertId) ->
          $http.get("/api/requests/expert/#{expertId}")
            .success (data) =>
              $scope.expertRequests = data
              $scope.expertStats = @buildStats(expertId, data)
            .error (data) ->
              console.log('Error: ' + data)

        buildStats: (expertId, requests) ->
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

      $scope.updateExpert()
