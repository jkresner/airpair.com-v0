LoginController = ($scope, Session) ->
  $scope.user = Session.data.user
  $scope.session = Session

  capitalize = (input) ->
    input.charAt(0).toUpperCase() + input.slice(1)
  camelize = (input) ->
    pieces = input.split(/[\W_-]/)
    _.map(pieces, capitalize).join("")

  $scope.trackLogin = ->
    if Session.data.returnTo
      Session.trackEvent("#{camelize(Session.data.returnTo)}Login")

angular
  .module('ngAirPair')
  .controller('LoginController', ['$scope', 'Session', LoginController])
