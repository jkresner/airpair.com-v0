


# Order metrics controller

angular.module('AirpairAdmin').controller("ChannelsRequestsCtrl", ['$scope', '$location', 'apData', ($scope, $location, apData) ->


  $scope.dateStart = moment().startOf("week").subtract("w", 2).toDate()
  $scope.dateEnd = moment().endOf('week').toDate()

  # $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd)
  updateRange = ->
    return if not $scope.dateStart or not $scope.dateEnd
    apData.orders.getGrowthRequests moment($scope.dateStart), moment($scope.dateEnd), ->
      $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd, "requests")
      $scope.$apply() if not $scope.$$phase

  # Watch date updates
  $scope.$watch "dateStart", () -> updateRange()
  $scope.$watch "dateEnd", (n, o) -> if n isnt o then updateRange()


])
