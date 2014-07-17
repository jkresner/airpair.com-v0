module.exports = (app) ->
  window.app.controller('headerController', ['$scope', 'global',
    ($scope, global) ->
      $scope.global = global
  ])
