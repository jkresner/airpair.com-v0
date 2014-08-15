HeaderController = ($rootScope, $scope, Session, CurrentExpert) ->
  $scope.session = Session
  $scope.expert = CurrentExpert
  $scope.helper =
    status: (value) =>
      $scope.expert.status == "ready"

angular
  .module('ngAirPair')
  .controller('HeaderController', ['$rootScope', '$scope', 'Session', 'CurrentExpert', HeaderController])
