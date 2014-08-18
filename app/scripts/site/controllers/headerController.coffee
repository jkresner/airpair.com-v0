HeaderController = ($rootScope, $scope, Session, CurrentExpert) ->
  $scope.session = Session
  $scope.expert = CurrentExpert

angular
  .module('ngAirPair')
  .controller('HeaderController', ['$rootScope', '$scope', 'Session', 'CurrentExpert', HeaderController])
