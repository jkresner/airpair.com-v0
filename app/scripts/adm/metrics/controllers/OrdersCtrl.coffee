

# Orders Controller

angular.module('AirpairAdmin').controller("OrdersCtrl", [ '$scope', '$location', '$filter', '$window', '$moment', 'apData', ($scope, $location, $filter, $window, $moment, apData) ->

  allOrders = apData.orders.get()
  firstOrderDate = moment(allOrders[0].utc).subtract('d', 1)
  firstMonth = moment(firstOrderDate).subtract('M', 1)

  # Get past months and years
  $scope.months = $moment.months firstMonth
  $scope.years = $moment.years firstMonth
  # Set default date range to 6 weeks
  $scope.dateRange = "6 weeks"
  $scope.orderViewLimit = 40

  updateDateRange = (newRange) ->
    return if not newRange
    date = new Date()
    if _.isString(newRange)
      switch newRange
        when "all"
          $scope.dateStart = firstOrderDate.toDate()
          $scope.dateEnd = date
        when "6 weeks"
          $scope.dateStart = moment().subtract("weeks", 6).toDate()
          $scope.dateEnd = date
        when "month"
          $scope.dateStart = moment().startOf("month").toDate()
          $scope.dateEnd = date
        when "week"
          now = moment()
          if now.day() < 6
            start = now.startOf("week").subtract("d", 1)
          else
            start = now.endOf("week").startOf("day")
          $scope.dateStart = start.toDate()
          $scope.dateEnd = start.clone().add("week", 1).subtract('d', 1).endOf('day').toDate()
        when "day"
          $scope.dateStart = moment().startOf("day").toDate()
          $scope.dateEnd = date
    if _.isObject(newRange)
      $scope.dateStart = newRange.start
      $scope.dateEnd = newRange.end

  newSearch = true
  updateOrderList = (searchText) ->
    # console.log "updateOrderList"
    $scope.orderViewLimit = 40
    # Search all if new search is starting
    return if not $scope.dateStart or not $scope.dateEnd
    if searchText and newSearch
      $scope.dateRange = 'all'
      newSearch = false
    if not searchText then newSearch = true
    $scope.visibleOrders = apData.orders.filter $scope.dateStart, $scope.dateEnd, $scope.orderSearch


  $scope.setDateRange = (range) -> $scope.dateRange = range

  $scope.getDateStr = () ->
    if _.isString($scope.dateRange) then $scope.dateRange
    else if _.isObject($scope.dateRange) then $scope.dateRange.str

  # Watch date updates
  $scope.$watch "dateRange", (newRange) -> updateDateRange(newRange)
  $scope.$watch "dateStart", (n, o) -> updateOrderList()
  $scope.$watch "dateEnd", (n, o) -> if n isnt o then updateOrderList()
  $scope.$watch "orderSearch", (searchText, o) -> if searchText isnt o then updateOrderList(searchText)

  # updateOrderList()



  angular.element($window).bind "scroll", (e) ->
    if $window.scrollY > 600
      if $scope.orderViewLimit isnt allOrders.length
        $scope.orderViewLimit = allOrders.length
        $scope.$apply() if not $scope.$$phase


])



