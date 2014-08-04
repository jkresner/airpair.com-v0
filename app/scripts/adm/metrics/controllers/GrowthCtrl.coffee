


# Monthly growth controller

angular.module('AirpairAdmin').controller("GrowthCtrl", ['$scope', '$location', 'apData', ($scope, $location, apData) ->

  $scope.getMonth = (index) ->
    date = new Date(2014, index, 1)
    month = moment(date).format("MMM")


  apData.orders.getGrowth 'monthly', null, null, (month2month) ->
    console.log "month2month", month2month
    $scope.report = month2month.report
    $scope.reportTotals = month2month.reportTotals
    $scope.$apply() if not $scope.$$phase









])

