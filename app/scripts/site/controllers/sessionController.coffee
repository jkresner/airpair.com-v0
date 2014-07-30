SessionController = ($scope, Session) ->
  $scope.session = Session

angular
  .module('ngAirPair')
  .controller('SessionController', ['$scope', 'Session', SessionController])
