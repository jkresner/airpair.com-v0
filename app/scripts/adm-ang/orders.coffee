calcExpertCredit = require 'lib/mix/calcExpertCredit'

{calcTotal, calcRedeemed, calcCompleted} = calcExpertCredit




module.exports = (pageData) ->



  # Create new app
  angular.module("AirpairAdmin", ["ngRoute", "ui.bootstrap"]).




  # Configs
  config(($routeProvider, $locationProvider) ->

    $locationProvider.html5Mode true

    $routeProvider.
      when('/adm/ang/orders/metrics',   {controller: 'MetricsCtrl',  templateUrl: "/adm/templates/orders_metrics.html"}).
      when('/adm/ang/orders/edit/:id',  {controller: 'OrdersCtrl',  templateUrl: "/adm/templates/orders_edit.html"}).
      when('/adm/ang/orders',           {controller: 'OrdersCtrl',  templateUrl: "/adm/templates/orders.html"}).
      otherwise({redirectTo: '/'})
  ).




  # Filters

  # TODO: use angular's built-in filters

  filter('pFormat', ($sce) ->
    (input, ratio) ->
      if ratio
        formatCss = if ratio > 0 then "g" else "r"
        $sce.trustAsHtml "<div class='#{formatCss}'>#{Math.round(ratio*100)}%</div>"
      else
        $sce.trustAsHtml "<div>#{input}</div>"
  ).


  filter('dollar', ->
    (input) -> "$#{input}"
  ).

  filter('percent', ->
    (input) -> "#{Math.round(input*100)}%"
  ).



  # Airpair Data Service
  #----------------------------------------------
  factory('apData', () ->
    
    apData = 
      orders: 
        data: pageData.orders
        get: () ->
          @data
        calcCredits: () ->
          console.log "calcCredits"
          for order in @data
            order.lineItems = order.lineItems.map (li) ->
              expertCredit = calcExpertCredit [order], li.suggestion.expert._id
              li.incomplete = expertCredit.total is 0 or expertCredit.completed < expertCredit.total
              _.extend li, expertCredit
        

    apData.orders.calcCredits()

    return apData
  ).








  # CONTROLLERS
  #----------------------------------------------



  # Nav Controller
  controller("NavCtrl", ["$scope", "$location", ($scope, $location) ->
    # A function to add class to nav items
    $scope.navClass = (page) ->
      currentRoute = $location.path().substring(16) or "browse"
      if page is currentRoute then "active" else ""
  ]).




  # Orders Controller

  controller("OrdersCtrl", ["$scope", "$location", "apData", ($scope, $location, apData) ->

    allOrders = apData.orders.get()

    firstOrderDate = new Date(allOrders[0].utc)

    # Get past 6 months
    $scope.months = []

    cur = moment(new Date())
    for num in [1..8]
      $scope.months.push
        str: cur.format("MMM")
        start: cur.startOf("month").clone().toDate()
        end: cur.endOf("month").clone().toDate()
      cur = cur.subtract('months', 1)


    # Set default date range to 6 weeks
    $scope.dateRange = "6 weeks"





    $scope.isWithinDate = (order) ->
      orderDate = new Date(order.utc)
      return orderDate > $scope.dateStart && orderDate < $scope.dateEnd

    $scope.updateDateRange = (newRange) ->
      date = new Date()
      if _.isString(newRange)
        switch newRange
          when "all"
            $scope.dateStart = firstOrderDate
            $scope.dateEnd = date
          when "6 weeks"
            $scope.dateStart = moment().subtract("weeks", 6).toDate()
            $scope.dateEnd = date
          when "month"
            $scope.dateStart = moment().startOf("month").toDate()
            $scope.dateEnd = date
          when "week"
            $scope.dateStart = moment().startOf("week").toDate()
            $scope.dateEnd = date
          when "day"
            $scope.dateStart = moment().startOf("day").toDate()
            $scope.dateEnd = date
      if _.isObject(newRange)
        $scope.dateStart = newRange.start
        $scope.dateEnd = newRange.end


    $scope.setDateRange = (range) ->
      $scope.dateRange = range

    $scope.getDateStr = () ->
      if _.isString($scope.dateRange) then $scope.dateRange
      else if _.isObject($scope.dateRange) then $scope.dateRange.str



    $scope.updateOrderList = () ->
      $scope.visibleOrders = []
      for order in allOrders
        if $scope.isWithinDate(order)
          $scope.visibleOrders.push order
      $scope.calcSummary()

    $scope.calcSummary = () ->
      $scope.summary =
        totalRevenue: 0
        orderCount: 0
        customerCount: 0
        requestCount: 0
        totalRedeemed: 0
        totalCompleted: 0
        totalHours: 0
        expertCount: 0
        totalProfit: 0
        experts: []

      for order in $scope.visibleOrders
        if $scope.isWithinDate(order)
          $scope.summary.totalRevenue += order.total
          $scope.summary.totalProfit += order.profit
          for item in order.lineItems
            $scope.summary.totalRedeemed += calcRedeemed [item]
            $scope.summary.totalCompleted += calcCompleted [item]
            $scope.summary.totalHours += calcTotal [item]
            $scope.summary.experts.push item.suggestion.expert._id

      $scope.summary.orderCount = $scope.visibleOrders.length
      $scope.summary.customerCount = _.uniq(_.pluck $scope.visibleOrders, 'userId').length
      $scope.summary.requestCount = _.uniq(_.pluck $scope.visibleOrders, 'requestId').length
      $scope.summary.expertCount = _.uniq($scope.summary.experts).length


    # Watch date updates
    $scope.$watch "dateStart", () -> $scope.updateOrderList()
    $scope.$watch "dateEnd", () -> $scope.updateOrderList()
    $scope.$watch "dateRange", (newRange) -> $scope.updateDateRange(newRange)





    # Month to Month report
    #----------------------------------------------


    $scope.reportVisible = false
    $scope.report = {}

    $scope.toggleReport = () ->
      if $scope.reportVisible then return $scope.reportVisible = false

      # Generate Report Data
      scopereport = []
      report = {}
      reportTotals =
        customerTotal: 0
        hrsSold: 0
        numMonths: 0
        revPerHour: 0
        revenue: 0
        gross: 0
        margin: 0

      for order in allOrders
        # year = moment(order.utc).year()
        # month = moment(order.utc).month()
        # yearmonth = moment(new Date(year, month, 1))
        monthName = moment(order.utc).format("MMM")
        monthIdx = moment(order.utc).format("YYMM")

        # if not report[year] then report[year] = {}
        if not report[monthIdx]
          report[monthIdx] =
            revenue: 0
            gross: 0
            hrsSold: 0
            orders: []
            monthIdx: monthIdx
            monthName: monthName
            # monthName:  moment(new Date(year, month, 1)).format("MMM")
            # monthNum: month

        m = report[monthIdx]

        # report[year].$yearName = moment(new Date(year, month, 1)).format("YYYY")

        m.orders.push order

        m.revenue += order.total
        m.gross += order.profit

        for item in order.lineItems
          m.hrsSold += calcTotal [item]

      last = null
      # _.each report, (year) ->
      _.each report, (month) ->
        # console.log "month", month.monthName

        month.customerTotal = _.uniq(_.pluck month.orders, 'userId').length
        month.hrPerCust = month.hrsSold/month.customerTotal
        month.revPerHour = month.revenue/month.hrsSold
        month.margin = month.gross/month.revenue

        reportTotals.numMonths++
        reportTotals.customerTotal += month.customerTotal
        reportTotals.hrsSold += month.hrsSold
        reportTotals.revPerHour += month.revPerHour
        reportTotals.revenue += month.revenue
        reportTotals.gross += month.gross
        reportTotals.margin += month.margin


        if last?
          scopereport.push
            css: 'change'
            monthIdx: "#{last.monthIdx}c#{month.monthIdx}"
            pcustomerTotal: (month.customerTotal-last.customerTotal)/last.customerTotal
            phrPerCust: (month.hrPerCust-last.hrPerCust)/last.hrPerCust
            phrsSold: (month.hrsSold-last.hrsSold)/last.hrsSold
            prevPerHour: (month.revPerHour-last.revPerHour)/last.revPerHour
            prevenue: (month.revenue-last.revenue)/last.revenue
            pgross: (month.gross-last.gross)/last.gross
            pmargin: (month.margin-last.margin)/last.margin

        scopereport.push month

        last = month


      reportTotals.revPerHour = reportTotals.revPerHour/reportTotals.numMonths
      reportTotals.margin = reportTotals.margin/reportTotals.numMonths
      reportTotals.hrPerCust = reportTotals.hrsSold/reportTotals.customerTotal
      reportTotals.ltv = reportTotals.margin*reportTotals.revPerHour*reportTotals.hrPerCust


      # Update Scope
      $scope.report = _.sortBy(scopereport, (m) -> m.monthIdx).reverse()
      $scope.reportTotals = reportTotals

      console.log "order", _.pluck $scope.report, 'monthIdx'
      # console.log "$scope.report", $scope.report, $scope.reportTotals
      $scope.reportVisible = true


      # $scope.getYear = (index) ->
      #   if index is 0
      #     return "2013"
      #   if index is 1
      #     return "2014"

      $scope.getMonth = (index) ->
        date = new Date(2014, index, 1)
        month = moment(date).format("MMM")

  ]).






  # Order metrics controller

  controller("MetricsCtrl", ["$scope", "$location", "apData", ($scope, $location, apData) ->
    console.log "metrics data", apData.orders.get()

    

  ])






