ExpertController = ($scope, Session) ->
  $scope.user = Session.data.user
  $scope.session = Session

angular
  .module('ngAirPair')
  .controller('ExpertController', ['$scope', 'Session', ExpertController])
