HeaderController = ($scope, Session, Expert) ->
  $scope.session = Session
  $scope.expert = Expert

angular
  .module('ngAirPair')
  .controller('HeaderController', ['$scope', 'Session', 'Expert', HeaderController])
