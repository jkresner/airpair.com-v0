module.exports = (app) ->
  window.app.controller 'headerController',
    ($scope, Session) ->
      $scope.session = Session
