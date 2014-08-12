ComingController = ($scope, Restangular) ->
  feedbackodel = Restangular.all("feedback")
  $scope.feedback = ""
  $scope.saved = false
  $scope.save = ->
    feedbackodel.post(message: $scope.feedback)
    $scope.saved = true

angular
  .module('ngAirPair')
  .controller('ComingController', ['$scope', 'Restangular', ComingController])
