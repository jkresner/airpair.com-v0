module.exports = (app) ->
  app.controller('ExpertSettingsController', ['$scope', '$http', '$window', 'global',
    ($scope, $http, $window, global) ->
      $scope.name = "expertsController"
  ])
