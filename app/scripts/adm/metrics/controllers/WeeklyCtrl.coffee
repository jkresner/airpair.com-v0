



# Weekly Summary controller

angular.module('AirpairAdmin').controller("WeeklyCtrl", ['$scope', '$location', '$moment', 'apData', ($scope, $location, $moment, apData ) ->


  # Overall Growth
  $scope.dateStart = moment().subtract('w', 4).toDate()

  # TODO
  now = moment()
  if now.day() < 6
    now.endOf("week").subtract("d", 1)
  else
    now.endOf("week").add('w', 1).subtract("d", 1).endOf("day")

  # now = moment()
  # if now.day() < 6
  #   now.clone().startOf("week").subtract("d", 1)
  # else
  #   now.clone().endOf("week").add('w', 1).subtract("d", 1).endOf("day")

  $scope.dateEnd = now.toDate()
  # $scope.dateEnd = moment().subtract('d', 1).toDate()


  updateRange = () ->
    return if not $scope.dateStart or not $scope.dateEnd
    # $scope.dateEnd = moment($scope.dateEnd).endOf('day').toDate()
    # console.log "updateRange()"

    apData.orders.getGrowth 'weekly', moment($scope.dateStart).startOf('day'), moment($scope.dateEnd).endOf('day'), (week2week) ->
      $scope.report = week2week.report
      $scope.reportTotals = week2week.reportTotals
      $scope.$apply() if not $scope.$$phase

    $scope.channelGrowth = apData.orders.getChannelGrowth(moment($scope.dateStart), moment($scope.dateEnd))
    $scope.channelGrowthSummary = apData.orders.getChannelGrowthSummary($scope.channelGrowth)


    apData.orders.getGrowthRequests ->
      $scope.channelGrowthRequests = apData.orders.getChannelGrowth(moment($scope.dateStart), moment($scope.dateEnd), "requests")
      $scope.channelGrowthRequestsSummary = apData.orders.getChannelGrowthSummary($scope.channelGrowthRequests)
      $scope.$apply() if not $scope.$$phase
      console.log "$scope.channelGrowthRequests", $scope.channelGrowthRequests




    # console.log "channelGrowth", $scope.channelGrowth
    # console.log "channelGrowthSummary", $scope.channelGrowthSummary




  $scope.lastWeekView = false
  $scope.showLastWeek = ->
    console.log "$scope.lastWeekView", $scope.lastWeekView
    if not $scope.lastWeekView
      start = moment().subtract('w', 1)
      if start.day() < 6
        start.startOf("week").subtract("d", 1).startOf("day")
      else
        start.endOf("week").startOf("day")
      $scope.dateStart = start.toDate()
      $scope.dateEnd = moment().toDate()





  # Watch date ranges
  first = true
  $scope.$watch "dateStart", () ->
    if first then return first = false
    updateRange()
  $scope.$watch "dateEnd", () -> updateRange()






])