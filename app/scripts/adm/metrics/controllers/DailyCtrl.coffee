
# DAILY

angular.module('AirpairAdmin').controller("DailyCtrl", ['$scope', '$moment', '$timeout', 'apData', ($scope, $moment, $timeout, apData ) ->


  _.extend $scope,
    dateStart: moment().subtract('w', 3).toDate()
    dateEnd: moment().toDate()


  updateRange = ->
    console.log "updateRange(#{$scope.searchString})"
    return if not $scope.dateStart or not $scope.dateEnd
    $scope.weeks = apData.ads.daily moment($scope.dateStart), moment($scope.dateEnd), $scope.searchString, ->
      $scope.$apply() if not $scope.$$phase

    console.log "daily report", $scope.weeks



  # Watch date ranges
  first = true
  $scope.$watch "dateStart", () ->
    if first then return first = false
    updateRange()
  $scope.$watch "dateEnd", () -> updateRange()



  # Delayed action method
  delay = (->
    timer = 0
    (callback, ms) ->
      clearTimeout timer
      timer = setTimeout(callback, ms)
      return
  )()

  # Delayed Search
  $scope.$watch "searchString", (n, o) ->
    if n isnt o
      delay ->
        return updateRange()
      , 500







])
