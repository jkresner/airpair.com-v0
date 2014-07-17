HeaderController = ($scope, Session) ->
  $scope.session = Session

angular
  .module('ngAirPair')
  .controller('HeaderController', ['$scope', 'Session', HeaderController])

