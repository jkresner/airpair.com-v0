module.exports = (app) ->
  app.controller('ExpertSettingsController', ['$scope', '$http', '$window', 'Session',
    ($scope, $http, $window, Session) ->
      $scope.name = "expertsController"

      $scope.updateExpert = ->
        $http.get("/api/experts/me")
          .success (data) ->
            $scope.expert = data
          .error (data) ->
            console.log('Error: ' + data)

      $scope.updateExpert()
  ])
