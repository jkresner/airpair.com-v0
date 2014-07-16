module.exports = (app) ->
  app.controller('ExpertsController', ['$scope', '$http', '$window', 'global',
    ($scope, $http, $window, global) ->
      $scope.name = "expertsController"
      console.log("expertsController")
  ])
