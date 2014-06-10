calcExpertCredit = require 'lib/mix/calcExpertCredit'

{calcTotal, calcRedeemed, calcCompleted} = calcExpertCredit




module.exports = (pageData) ->



  # Create new app
  angular.module("AirpairAdmin", ["ngRoute", "ui.bootstrap"]).




  # Configs
  config(($routeProvider, $locationProvider) ->

    $locationProvider.html5Mode true

    $routeProvider.
      when('/adm/ang/orders/growth',    {controller: 'GrowthCtrl',   templateUrl: "/adm/templates/orders_growth.html"}).
      when('/adm/ang/orders/channels',  {controller: 'ChannelsCtrl', templateUrl: "/adm/templates/orders_channels.html"}).
      when('/adm/ang/orders/edit/:id',  {controller: 'OrdersCtrl',   templateUrl: "/adm/templates/orders_edit.html"}).
      when('/adm/ang/orders',           {controller: 'OrdersCtrl',   templateUrl: "/adm/templates/orders.html"}).
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
    
    window.apData = 
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
        
        getMetrics: (start, end) ->
          if not @metrics
            @metrics = []
            for order in apData.orders.data
              metric = 
                utc: order.utc
                name: order.company.contacts[0].fullName
                tags: {}
                total: order.total
                campaigns: []
                requestId: order.requestId
              _.each order.marketingTags, (tag) ->
                if tag.type is "channel" or tag.type is "campaign"
                  metric.tags[tag.group] = tag
                  metric.tags[tag.group].total = metric.total/order.marketingTags.length 
                  if tag.type is "campaign"
                    metric.campaigns.push(tag.name)
              @metrics.push metric
            _(@metrics).reverse()
          
          if start and end
            @metricsFiltered = []
            for order in @metrics
              date = new Date(order.utc)
              if date >= start and date <= end
                @metricsFiltered.push order
            return orders: @metricsFiltered, summary: @getMetricsSummary(@metricsFiltered)
          
          else 
            return orders: @metrics, summary: @getMetricsSummary(@metrics)

        getMetricsSummary: (metrics) ->
          summary = 
            numOrders: metrics.length 
            revenueTotal: 0
            tags: {}

          for order in metrics
            summary.revenueTotal += order.total
            _.each order.tags, (tag) ->
              if not summary.tags[tag.group]
                summary.tags[tag.group] = 
                 count: 0
                 revenue: 0
              summary.tags[tag.group].count++ 
              summary.tags[tag.group].revenue += tag.total

          @metricsSummary = summary

              
            
            




        
        
        


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

  controller("OrdersCtrl", ["$scope", "$location", "$filter", "apData", ($scope, $location, $filter, apData) ->

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
      return if not newRange
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


    $scope.search = (text) ->
      return if not text
      if text.length > 2
        $scope.dateRange = ''
        $scope.visibleOrders = $filter('filter')(allOrders, text)
        $scope.calcSummary()


    # Watch date updates
    $scope.$watch "dateStart", () -> $scope.updateOrderList()
    $scope.$watch "dateEnd", () -> $scope.updateOrderList()
    $scope.$watch "dateRange", (newRange) -> $scope.updateDateRange(newRange)
    
    # Search updates
    $scope.$watch "orderSearch", (text) -> $scope.search(text)



  ]).








  # Monthly and weekly growth controller

  controller("GrowthCtrl", ["$scope", "$location", "apData", ($scope, $location, apData) ->

    allOrders = apData.orders.get()

    
    # Month to Month report

    $scope.report = {}
    $scope.generateM2M = () ->
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


    $scope.getMonth = (index) ->
      date = new Date(2014, index, 1)
      month = moment(date).format("MMM")


    $scope.generateM2M()

  ]).








  # Order metrics controller

  controller("ChannelsCtrl", ["$scope", "$location", "apData", ($scope, $location, apData) ->

    $scope.dateStart = moment().startOf("week").subtract("w", 2).toDate()
    $scope.dateEnd = moment().endOf('week').toDate()


    $scope.metrics = apData.orders.getMetrics($scope.dateStart, $scope.dateEnd)

    # Watch date updates
    $scope.$watch "dateStart", () -> $scope.metrics = apData.orders.getMetrics($scope.dateStart, $scope.dateEnd)
    $scope.$watch "dateEnd", () -> $scope.metrics = apData.orders.getMetrics($scope.dateStart, $scope.dateEnd)






  ])






