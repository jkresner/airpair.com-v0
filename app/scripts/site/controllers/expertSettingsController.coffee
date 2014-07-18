module.exports = (app) ->
  app.controller('ExpertSettingsController', ['$scope', '$http', '$window', 'Session',
    ($scope, $http, $window, Session) ->
      $scope.name = "expertsController"
  ])
