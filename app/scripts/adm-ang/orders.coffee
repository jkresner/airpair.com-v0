calcExpertCredit = require 'lib/mix/calcExpertCredit'

{calcTotal, calcRedeemed, calcCompleted} = calcExpertCredit




module.exports = (pageData) ->



  # Create new app
  angular.module("AirpairAdmin", ["ngRoute", "ui.bootstrap"]).




  # Configs
  config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->

    $locationProvider.html5Mode true

    $routeProvider.
      when('/adm/ang/orders/growth',    { controller: 'GrowthCtrl',   templateUrl: "/adm/templates/orders_growth.html"}).
      when('/adm/ang/orders/channels',  { controller: 'ChannelsCtrl', templateUrl: "/adm/templates/orders_channels.html"}).
      when('/adm/ang/orders/weekly',    { controller: 'WeeklyCtrl',   templateUrl: "/adm/templates/orders_weekly.html"}).
      when('/adm/ang/orders/edit/:id',  { controller: 'OrdersCtrl',   templateUrl: "/adm/templates/orders_edit.html"}).
      when('/adm/ang/orders',           { controller: 'OrdersCtrl',   templateUrl: "/adm/templates/orders.html"}).
      otherwise({redirectTo: '/'})
  ]).






  # Moment Service - For date logic
  #----------------------------------------------

  factory('$moment', () ->
    $moment =
      months: (start) ->
        months = []
        cur = moment()
        while cur.isAfter(start)
          months.push
            str: cur.format("MMM YY")
            start: cur.clone().startOf("month").toDate()
            end: cur.clone().endOf("month").toDate()
          cur = cur.subtract('months', 1)
        return months
      years: (start) ->
        years = []
        curYear = moment(new Date()).startOf("year")
        while curYear.isAfter(start)
          years.push
            str: curYear.format("YYYY")
            start: curYear.startOf("year").clone().toDate()
            end: curYear.endOf("year").clone().toDate()
          curYear = curYear.subtract('y', 1)
        return years

      getWeeks: (start, end = moment().endOf('month')) ->
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

      getWeeksByFriday: (start) ->

        if not start
          start = moment().startOf('month').subtract("days", 2)
        else
          start.startOf('week').subtract("days", 2)

        if start.day() < 6
          start.startOf("week").subtract("d", 1).startOf("day")
        else
          start.endOf("week").startOf("day")


        weeks = []

        cur = moment(new Date())
        if cur.day() < 6
          cur.startOf("week").subtract("d", 1).startOf("day")
        else
          cur.endOf("week").startOf("day")


        while cur.isAfter(start)
          weeks.push
            str: cur.clone().add('w', 1).subtract('d', 1).format("MMM D")
            start: cur.toDate()
            end: cur.clone().add('w', 1).toDate()
          cur = cur.clone().subtract('w', 1)


        return weeks


  ).





  # Airpair Data Service
  #----------------------------------------------

  factory('apData', ['$moment', '$filter', ($moment, $filter) ->

    window.apData =
      orders:
        data: pageData.orders
        get: () ->
          @data

        filter: (start, end, searchText) ->
          visibleOrders = []
          for order in @data
            if @isWithinDate(order, start, end)
              visibleOrders.push order
          if searchText
            visibleOrders = $filter('filter')(visibleOrders, searchText)
          return {
            orders: visibleOrders
            summary: @calcSummary(visibleOrders)
          }


        isWithinDate: (order, start, end) ->
          orderDate = new Date(order.utc)
          return orderDate > start && orderDate < end

        calcSummary: (orders) ->
          summary =
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
          for order in orders
            summary.totalRevenue += order.total
            summary.totalProfit += order.profit
            for item in order.lineItems
              summary.totalRedeemed += calcRedeemed [item]
              summary.totalCompleted += calcCompleted [item]
              summary.totalHours += calcTotal [item]
              summary.experts.push item.suggestion.expert._id
          summary.orderCount = orders.length
          summary.customerCount = _.uniq(_.pluck orders, 'userId').length
          summary.requestCount = _.uniq(_.pluck orders, 'requestId').length
          summary.expertCount = _.uniq(summary.experts).length

          return summary








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
                # Find start of saturday
                time = moment(order.utc)
                if time.day() < 6
                  time.startOf("week").subtract("d", 1).startOf("day")
                else
                  time.endOf("week").startOf("day")

                intervalName = time.clone().add('days', 6).format("MMM D")
                intervalIdx = time.format("YYMMDD")

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
            console.log 'period', period.intervalIdx, period

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


          # Calc last week based on where we would have been

          if interval is "weekly"

            console.log "LAST WEEK"

            # Get current week index
            time = moment()
            if time.day() < 6
              time.startOf("week").subtract("d", 1).startOf("day")
            else
              time.endOf("week").startOf("day")

            curWeekIdx = time.format("YYMMDD")


            finalWeek = report[report.length - 1]

            console.log "curWeekIdx", curWeekIdx
            console.log "finalWeek", finalWeek.intervalIdx


            # curWeekIdx = "140614" # test

            if curWeekIdx is finalWeek.intervalIdx

              # console.log "last week math"

              finalDiff = report[report.length - 2]
              prevWeek = report[report.length - 3]

              # console.log "finalDiff", finalDiff
              # console.log "prevWeek", prevWeek


              # Get week percentage
              wkStart = moment()
              if wkStart.day() < 6
                wkStart.startOf("week").subtract("d", 1).startOf("day")
              else
                wkStart.endOf("week").startOf("day")
              wkPercentage = (moment().unix()-wkStart.unix())/60/60/24/7
              console.log "wkPercentage", wkPercentage

              _.extend finalDiff,
                intervalName: "#{Math.floor(wkPercentage*100)}%"
                pcustomerTotal: (finalWeek.customerTotal / (prevWeek.customerTotal*wkPercentage)) - 1
                phrsSold: (finalWeek.hrsSold / (prevWeek.hrsSold*wkPercentage)) - 1
                prevenue: (finalWeek.revenue / (prevWeek.revenue*wkPercentage)) - 1
                pgross: (finalWeek.gross / (prevWeek.gross*wkPercentage)) - 1



          if interval is "monthly"

            finalMonth = report[report.length - 1]
            finalDiff = report[report.length - 2]
            prevMonth = report[report.length - 3]

            monthPercentage = (moment().unix()-moment().startOf('month').unix()) / (moment().endOf('month').unix()-moment().startOf('month').unix())
            console.log "monthPercentage", monthPercentage

            _.extend finalDiff,
              intervalName: "#{Math.floor(monthPercentage*100)}%"
              pcustomerTotal: (finalMonth.customerTotal / (prevMonth.customerTotal*monthPercentage)) - 1
              phrsSold: (finalMonth.hrsSold / (prevMonth.hrsSold*monthPercentage)) - 1
              prevenue: (finalMonth.revenue / (prevMonth.revenue*monthPercentage)) - 1
              pgross: (finalMonth.gross/(prevMonth.gross*monthPercentage)) - 1

          console.log 'report', report.length

          # Sort, reverse, and return
          return {
            report: _.sortBy(report, (m) -> m.intervalIdx).reverse()
            reportTotals: reportTotals
          }


        getChannelMetrics: (start, end) ->
          if not @metrics
            @metrics = []
            # tags = []
            for order in apData.orders.data
              metric =
                utc: order.utc
                name: order.company.contacts[0].fullName
                tags: {}
                total: order.total
                campaigns: []
                requestId: order.requestId
                tags:
                  ad: {total:0, revenue: 0}
                  affiliate: {total:0, revenue: 0}
                  direct: {total:0, revenue: 0}
                  incubator: {total:0, revenue: 0}
                  newsletterairpair: {total:0, revenue: 0}
                  press: {total:0, revenue: 0}
                  # product: {total:0, revenue: 0}
                  seo: {total:0, revenue: 0}
                  social: {total:0, revenue: 0}
                  wordofmouth: {total:0, revenue: 0}
                  untracked: {total:0, revenue: 0}
                  # stackoverflowads: {total:0, revenue: 0}

              _.each order.marketingTags, (tag) ->
                channelTags = _.where order.marketingTags, { type: "channel" }
                tagName = tag.group.replace('-', '')
                if tag.type is "channel"
                  if tag.name is "w-o-mouth"
                    tagName = "wordofmouth"
                  # tags.push tagName
                  metric.tags[tagName] = tag
                  metric.tags[tagName].total = metric.total/channelTags.length
                if tag.type is "campaign"
                  metric.campaigns.push(tag.name)
              @metrics.push metric
            # tags = _.uniq(tags)

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
            _.each order.tags, (tag, key) ->
              if not summary.tags[key]
                summary.tags[key] =
                 count: 0
                 revenue: 0
              summary.tags[key].count++ if tag.name
              summary.tags[key].revenue += tag.total

          # console.log "@metricsSummary", summary
          @metricsSummary = summary


        getChannelGrowth: (start = moment(@data[0].utc), end = moment()) ->

          weeks = $moment.getWeeksByFriday(moment().subtract("weeks", 4), moment(), 6).reverse()

          # Get Metrics for each week
          prev = null
          for week in weeks
            week.metrics = @getChannelMetrics(week.start, week.end)
            if prev
              week.diffTags = {}
              _.each prev.metrics.summary.tags, (tag, tagName) ->
                if tagName is '' then return
                if not week.metrics.summary.tags[tagName]
                  week.metrics.summary.tags[tagName] =
                    count: 0

                newCount = week.metrics.summary.tags[tagName].count
                oldCount = tag.count
                week.diffTags[tagName] =
                  count: if oldCount is 0 then (newCount-oldCount) else (newCount/oldCount)-1
            prev = week


          # calc last week diff
          finalWeek = weeks[weeks.length - 1]
          prevWeek = weeks[weeks.length - 2]

          # get percentage through week
          wkStart = moment()
          if wkStart.day() < 6
            wkStart.startOf("week").subtract("d", 1).startOf("day")
          else
            wkStart.endOf("week").startOf("day")
          wkPercentage = (moment().unix()-wkStart.unix())/60/60/24/7

          # Update final week diff
          _.each finalWeek.metrics.summary.tags, (tag, tagName) ->
            if tagName is '' then return

            newCount = tag.count
            oldCount = prevWeek.metrics.summary.tags[tagName].count*wkPercentage

            finalWeek.diffTags[tagName] =
              count: if oldCount is 0 then (newCount-oldCount) else (newCount/oldCount)-1


          return weeks.reverse()







    apData.orders.calcCredits()

    console.log "apData", apData


    return apData
  ]).








  # CONTROLLERS
  #----------------------------------------------




  # Nav Controller
  controller("NavCtrl", [ '$scope', '$location', ($scope, $location) ->
    # A function to add class to nav items
    $scope.navClass = (page) ->
      currentRoute = $location.path().substring(16) or "browse"
      if page is currentRoute then "active" else ""
  ]).




  # Orders Controller

  controller("OrdersCtrl", [ '$scope', '$location', '$filter', '$window', '$moment', 'apData', ($scope, $location, $filter, $window, $moment, apData) ->

    allOrders = apData.orders.get()
    firstOrderDate = new Date(allOrders[0].utc)
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

    newSearch = true
    updateOrderList = (searchText) ->
      # Search all if new search is starting
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
    $scope.$watch "dateStart", () -> updateOrderList()
    $scope.$watch "dateEnd", () -> updateOrderList()
    $scope.$watch "orderSearch", (searchText) -> updateOrderList(searchText)




    angular.element($window).bind "scroll", (e) ->
      if $window.scrollY > 600
        if $scope.orderViewLimit isnt allOrders.length
          $scope.orderViewLimit = allOrders.length
          $scope.$apply() if not $scope.$$phase


  ]).








  # Monthly growth controller

  controller("GrowthCtrl", ['$scope', '$location', 'apData', ($scope, $location, apData) ->

    $scope.getMonth = (index) ->
      date = new Date(2014, index, 1)
      month = moment(date).format("MMM")

    month2month = apData.orders.getGrowth 'monthly'

    console.log "month2month", month2month

    $scope.report = month2month.report
    $scope.reportTotals = month2month.reportTotals


  ]).







  # Order metrics controller

  controller("ChannelsCtrl", ['$scope', '$location', 'apData', ($scope, $location, apData) ->


    $scope.dateStart = moment().startOf("week").subtract("w", 2).toDate()
    $scope.dateEnd = moment().endOf('week').toDate()

    $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd)

    # Watch date updates
    $scope.$watch "dateStart", () -> $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd)
    $scope.$watch "dateEnd", () -> $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd)


  ]).






  # Weekly Summary controller

  controller("WeeklyCtrl", ['$scope', '$location', '$moment', 'apData', ($scope, $location, $moment, apData ) ->

    # Overall Growth
    week2week = apData.orders.getGrowth 'weekly', moment().startOf('month').subtract('weeks', 7)
    $scope.report = week2week.report
    $scope.reportTotals = week2week.reportTotals


    # Channel Growth
    $scope.channelGrowth = apData.orders.getChannelGrowth(moment().subtract('weeks', 7))


  ])












