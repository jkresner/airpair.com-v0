
# DAILY

angular.module('AirpairAdmin').controller("DailyCtrl", ['$scope', '$moment', 'apData', ($scope, $moment, apData ) ->


  _.extend $scope,
    dateStart: moment().subtract('w', 3).toDate()
    dateEnd: moment().toDate()


  updateRange = (searchString) ->
    return if not $scope.dateStart or not $scope.dateEnd
    $scope.weeks = apData.ads.daily moment($scope.dateStart), moment($scope.dateEnd), searchString, ->
      $scope.$apply() if not $scope.$$phase

    console.log "daily report", $scope.weeks



  # Watch date ranges
  first = true
  $scope.$watch "dateStart", () ->
    if first then return first = false
    updateRange()
  $scope.$watch "dateEnd", () -> updateRange()
  $scope.$watch "searchString", (n, o) ->
    if n isnt o
      updateRange(n)

])
