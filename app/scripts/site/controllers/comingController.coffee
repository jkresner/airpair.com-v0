ComingController = ($scope, Restangular) ->
  feedbackModel = Restangular.all("feedback")
  $scope.feedback = ""
  $scope.saved = false
  $scope.save = ->
    feedbackModel.post(message: $scope.feedback)
    $scope.saved = true

angular
  .module('ngAirPair')
  .controller('ComingController', ['$scope', 'Restangular', ComingController])
