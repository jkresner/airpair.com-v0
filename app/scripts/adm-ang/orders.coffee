calcExpertCredit = require 'lib/mix/calcExpertCredit'

{calcTotal, calcRedeemed, calcCompleted} = calcExpertCredit




module.exports = (pageData) ->



  # Create new app
  angular.module("AirpairAdmin", ["ngRoute", "ui.bootstrap"]).




  # Configs
  config(($routeProvider, $locationProvider) ->

    $locationProvider.html5Mode true

    $routeProvider.
      when('/adm/ang/orders/growth',    { controller: 'GrowthCtrl',   templateUrl: "/adm/templates/orders_growth.html"}).
      when('/adm/ang/orders/channels',  { controller: 'ChannelsCtrl', templateUrl: "/adm/templates/orders_channels.html"}).
      when('/adm/ang/orders/weekly',    { controller: 'WeeklyCtrl',   templateUrl: "/adm/templates/orders_weekly.html"}).
      when('/adm/ang/orders/edit/:id',  { controller: 'OrdersCtrl',   templateUrl: "/adm/templates/orders_edit.html"}).
      when('/adm/ang/orders',           { controller: 'OrdersCtrl',   templateUrl: "/adm/templates/orders.html"}).
      otherwise({redirectTo: '/'})
  ).






  # Moment Service - For date logic
  #----------------------------------------------

  factory('$moment', () ->
    $moment = 
      getWeeks: (start, end = moment().endOf('month')) ->
        # if not month
        #   month = moment().startOf 'month'
        # else 
        #   month = month.startOf 'month'
        if not start
          start = moment().startOf('month').subtract("days", 1)
        else
          start = start.startOf("week").subtract("days", 1)

        weeks = []
        cur = moment(new Date()).startOf("week")
        while cur.isAfter(start)
          weeks.push
            str: cur.format("MMM D")
            start: cur.clone().toDate()
            end: cur.clone().endOf("week").toDate()
          cur = cur.subtract('weeks', 1)
        return weeks

  ).





  # Airpair Data Service
  #----------------------------------------------

  factory('apData', ($moment) ->
    
    window.apData = 
      orders: 
        data: pageData.orders
        get: () ->
          @data
        calcCredits: () ->
          for order in @data
            order.lineItems = order.lineItems.map (li) ->
              expertCredit = calcExpertCredit [order], li.suggestion.expert._id
              li.incomplete = expertCredit.total is 0 or expertCredit.completed < expertCredit.total
              _.extend li, expertCredit
        
        
        getGrowth: (interval = 'monthly', start = moment(@data[0].utc), end = moment()) ->


          periods = {}

          # Group orders by period. Calculate revenue, gross, and hrs sold. 
          for order in @data

            if moment(order.utc).isAfter(start)
                
              if interval is "monthly"
                intervalName = moment(order.utc).format("MMM")
                intervalIdx = moment(order.utc).startOf('month').format("YYMM")
              if interval is "weekly"
                intervalName = moment(order.utc).format("MMM D")
                intervalIdx = moment(order.utc).startOf('week').format("YYMMDD")

              if not periods[intervalIdx]
                periods[intervalIdx] =
                  revenue: 0
                  gross: 0
                  hrsSold: 0
                  orders: []
                  intervalIdx: intervalIdx
                  intervalName: intervalName

              period = periods[intervalIdx]
              period.orders.push order
              period.revenue += order.total
              period.gross += order.profit
              period.hrsSold += calcTotal [item] for item in order.lineItems
              



          # Calc more stats. Get differences.  
          report = []

          reportTotals =
            customerTotal: 0
            hrsSold: 0
            numPeriods: 0
            revPerHour: 0
            revenue: 0
            gross: 0
            margin: 0

          prevPeriod = null

          _.each periods, (period) ->
            period.customerTotal = _.uniq(_.pluck period.orders, 'userId').length
            period.hrPerCust = period.hrsSold/period.customerTotal
            period.revPerHour = period.revenue/period.hrsSold
            period.margin = period.gross/period.revenue

            reportTotals.numPeriods++
            reportTotals.customerTotal += period.customerTotal
            reportTotals.hrsSold += period.hrsSold
            reportTotals.revPerHour += period.revPerHour
            reportTotals.revenue += period.revenue
            reportTotals.gross += period.gross
            reportTotals.margin += period.margin

            # Calc differences between periods
            if prevPeriod?
              report.push
                css: 'change'
                intervalIdx: "#{prevPeriod.intervalIdx}c#{period.intervalIdx}"
                pcustomerTotal: (period.customerTotal-prevPeriod.customerTotal)/prevPeriod.customerTotal
                phrPerCust: (period.hrPerCust-prevPeriod.hrPerCust)/prevPeriod.hrPerCust
                phrsSold: (period.hrsSold-prevPeriod.hrsSold)/prevPeriod.hrsSold
                prevPerHour: (period.revPerHour-prevPeriod.revPerHour)/prevPeriod.revPerHour
                prevenue: (period.revenue-prevPeriod.revenue)/prevPeriod.revenue
                pgross: (period.gross-prevPeriod.gross)/prevPeriod.gross
                pmargin: (period.margin-prevPeriod.margin)/prevPeriod.margin
            
            report.push period
            prevPeriod = period

          
          # Final report totals
          reportTotals.revPerHour = reportTotals.revPerHour/reportTotals.numPeriods
          reportTotals.margin = reportTotals.margin/reportTotals.numPeriods
          reportTotals.hrPerCust = reportTotals.hrsSold/reportTotals.customerTotal
          reportTotals.ltv = reportTotals.margin*reportTotals.revPerHour*reportTotals.hrPerCust
          

          # Sort, reverse, and return
          return {
            report: _.sortBy(report, (m) -> m.intervalIdx).reverse()
            reportTotals: reportTotals
          }

          
        
        

        getChannelMetrics: (start, end) ->
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
            return orders: @metricsFiltered, summary: @getChannelMetricsSummary(@metricsFiltered)
          
          else 
            return orders: @metrics, summary: @getChannelMetricsSummary(@metrics)

        getChannelMetricsSummary: (metrics) ->
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





        getChannelGrowth: (start = moment(@data[0].utc), end = moment()) ->

          weeks = $moment.getWeeks(moment().subtract("weeks", 4))

          # Get Metrics for each week
          prev = null
          for week in weeks
            week.metrics = @getChannelMetrics(week.start, week.end)
            if prev
              week.metricsPrev = prev.metrics.summary
            prev = week

          return weeks
            



          
        
        
              
            
      

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

  controller("OrdersCtrl", ["$scope", "$location", "$filter", "$window", "apData", ($scope, $location, $filter, $window, apData) ->

    allOrders = apData.orders.get()
    firstOrderDate = new Date(allOrders[0].utc)
    firstMonth = moment(firstOrderDate).subtract('M', 1)

    # Get past months
    $scope.months = []
    cur = moment(new Date())
    while cur.isAfter(firstMonth)
      $scope.months.push
        str: cur.format("MMM YY")
        start: cur.startOf("month").clone().toDate()
        end: cur.endOf("month").clone().toDate()
      cur = cur.subtract('months', 1)
    # Get past years
    $scope.years = []
    curYear = moment(new Date()).startOf("year")
    while curYear.isAfter(firstMonth)
      $scope.years.push
        str: curYear.format("YYYY")
        start: curYear.startOf("year").clone().toDate()
        end: curYear.endOf("year").clone().toDate()
      curYear = curYear.subtract('y', 1)

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
      $scope.orderViewLimit = 40
      for order in allOrders
        if $scope.isWithinDate(order)
          $scope.visibleOrders.push order
      if $scope.orderSearch
        $scope.visibleOrders = $filter('filter')($scope.visibleOrders, $scope.orderSearch)

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
      if not text
        $scope.updateOrderList()
      else 
        $scope.dateRange = 'all'
        $scope.visibleOrders = $filter('filter')(allOrders, text)
        $scope.calcSummary()


    # Watch date updates
    $scope.$watch "dateStart", () -> $scope.updateOrderList()
    $scope.$watch "dateEnd", () -> $scope.updateOrderList()
    $scope.$watch "dateRange", (newRange) -> $scope.updateDateRange(newRange)
    
    # Search updates
    $scope.$watch "orderSearch", (text) -> $scope.search(text)


    angular.element($window).bind "scroll", (e) ->
      if $window.scrollY > 600
        if $scope.orderViewLimit isnt allOrders.length
          $scope.orderViewLimit = allOrders.length
          $scope.$apply() if not $scope.$$phase


  ]).








  # Monthly growth controller

  controller("GrowthCtrl", ["$scope", "$location", "apData", ($scope, $location, apData) ->

    $scope.getMonth = (index) ->
      date = new Date(2014, index, 1)
      month = moment(date).format("MMM")

    month2month = apData.orders.getGrowth 'monthly'

    $scope.report = month2month.report
    $scope.reportTotals = month2month.reportTotals


  ]).







  # Order metrics controller

  controller("ChannelsCtrl", ["$scope", "$location", "apData", ($scope, $location, apData) ->

    $scope.dateStart = moment().startOf("week").subtract("w", 2).toDate()
    $scope.dateEnd = moment().endOf('week').toDate()

    $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd)

    # Watch date updates
    $scope.$watch "dateStart", () -> $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd)
    $scope.$watch "dateEnd", () -> $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd)


  ]).






  # Weekly Summary controller

  controller("WeeklyCtrl", ["$scope", "$location", "$moment", "apData", ($scope, $location, $moment, apData ) ->

    # Overall Growth
    week2week = apData.orders.getGrowth 'weekly', moment().startOf('month').subtract('weeks', 7)
    $scope.report = week2week.report
    $scope.reportTotals = week2week.reportTotals



    # Channel Growth
    $scope.channelGrowth = apData.orders.getChannelGrowth(moment().subtract('weeks', 7))

    console.log "channelGrowth", $scope.channelGrowth



  ])












