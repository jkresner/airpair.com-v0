
# DAILY

angular.module('AirpairAdmin').controller("DailyCtrl", ['$scope', '$moment', '$timeout', 'apData', ($scope, $moment, $timeout, apData ) ->


  _.extend $scope,
    dateStart: moment().subtract('w', 3).toDate()
    dateEnd: moment().toDate()
    loading = false


  updateRange = ->
    console.log "updateRange(search: #{$scope.searchString}, newOnly: #{$scope.newOnly})"
    return if not $scope.dateStart or not $scope.dateEnd
    $scope.loading = true
    $scope.$apply() if not $scope.$$phase
    $scope.weeks = apData.ads.daily moment($scope.dateStart), moment($scope.dateEnd), $scope.searchString, $scope.newOnly, ->
      $scope.loading = false
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

  # Watch new only toggle
  $scope.$watch "newOnly", (n, o) -> if n isnt o then updateRange()






])
