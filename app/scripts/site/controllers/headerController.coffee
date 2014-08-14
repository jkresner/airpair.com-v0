HeaderController = ($rootScope, $scope, Session, Expert) ->
  $scope.session = Session
  Expert.get()
  $rootScope.$on 'event:expert-fetched', =>
    $scope.expert = $rootScope.expert
    $scope.helper =
      status: (value) =>
        $scope.expert.status == "ready"

angular
  .module('ngAirPair')
  .controller('HeaderController', ['$rootScope', '$scope', 'Session', 'Expert', HeaderController])
