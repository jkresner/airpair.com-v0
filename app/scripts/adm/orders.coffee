calcExpertCredit = require 'lib/mix/calcExpertCredit'
ObjectId2Date = require 'lib/mix/objectId2Date'

{calcTotal, calcRedeemed, calcCompleted} = calcExpertCredit




module.exports = (pageData) ->



  # Create new app
  angular.module("AirpairAdmin", ["ngRoute", "ui.bootstrap"]).




  # Configs
  config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->

    $locationProvider.html5Mode true

    $routeProvider.
      when('/adm/ang/orders/growth',    { controller: 'GrowthCtrl',   templateUrl: "/adm/templates/orders_growth.html", resolve: {title: () -> document.title = "Monthly" }}).
      when('/adm/ang/orders/channels',  { controller: 'ChannelsCtrl', templateUrl: "/adm/templates/orders_channels.html", resolve: {title: () -> document.title = "Channels" }}).
      when('/adm/ang/orders/weekly',    { controller: 'WeeklyCtrl',   templateUrl: "/adm/templates/orders_weekly.html", resolve: {title: () -> document.title = "Weekly" }}).
      when('/adm/ang/orders/edit/:id',  { controller: 'OrdersCtrl',   templateUrl: "/adm/templates/orders_edit.html", resolve: {title: () -> document.title = "Edit" }}).
      when('/adm/ang/orders',           { controller: 'OrdersCtrl',   templateUrl: "/adm/templates/orders.html", resolve: {title: () -> document.title = "Orders" }}).
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

  factory('apData', ['$moment', '$filter', '$http', ($moment, $filter, $http) ->

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



        
        # Get unique customers before a specific date.

        getCustomersBefore: (timeEnd) ->
          orders = []
          for order in @data
            if moment(order.utc).isBefore(timeEnd)
              orders.push order
          unique = _.uniq(_.pluck orders, 'userId')
          return unique


        

        # Get growth metrics

        getGrowthRequests: (callback = ->) ->
            

          # @growthStart = moment(@data[0].utc).subtract("d", 1)
          # @growthEnd = moment()

          # if not @growthRequests or not @growthRequestCalls
          startDate = @growthStart.format('YYYY-MM-DD')
          endDate = @growthEnd.format('YYYY-MM-DD')
          
          console.log "getGrowthRequests()", startDate, endDate

          count = 0
          api = {}
          # Get requests
          $http.get("/api/admin/requests/#{startDate}/#{endDate}").success (data, status, headers, config) =>
            console.log "API requests"
            @growthRequests = api.requests = data
            count++
            if count is 2 then callback(api)
          # Hrs on air
          $http.get("/api/admin/requests/calls/#{startDate}/#{endDate}").success (data, status, headers, config) =>
            console.log "API calls"
            @growthRequestCalls = api.calls = data
            count++
            if count is 2 then callback(api)
          # else
          #   callback(requests: @growthRequests, calls: @growthRequestCalls)


        
        filterGrowthRequests: (start, end, callback) ->
          # console.log "END?", end

          # console.log "filterGrowthRequests", start.format('YYYY-MM-DD'), "–", end.format('YYYY-MM-DD') 

          data = 
            requests: @growthRequests
            calls: @growthRequestCalls
          # @getGrowthRequests (data) ->


          filteredRequests = []
          filteredCalls = []
          
          for val, i in data.requests
            date = moment ObjectId2Date(val._id)
            # console.log "date", date.format('YYYY-MM-DD'), date.isAfter(start), date.isBefore(end) 
            if date.isAfter(start) and date.isBefore(end) 
              filteredRequests.push val


          for val, i in data.calls
            date = moment val.datetime
            if date.isAfter(start) and date.isBefore(end) then filteredCalls.push val              

          filtered =  {
            requests: filteredRequests
            calls: filteredCalls
          }

          # console.log "filtered = ", filtered
          callback filtered
          
            


        getGrowth: (interval = 'monthly', start = moment(@data[0].utc).subtract("d", 1), end = moment(), callback) ->

          console.group "getGrowth #{interval}"

          console.log "#{start.format('YYYY-MM-DD')} – #{end.format('YYYY-MM-DD')}"

          console.time("getGrowth")

          @growthStart = start
          @growthEnd = end


          # Get API requests first
          @getGrowthRequests =>
            
            console.log "... api calls completed. Crunching data.."
          
      

            # Group orders by period. Calculate revenue, gross, and hrs sold.
            
            periods = {}
            filteredOrders = []

            for order in @data

              if moment(order.utc).isAfter(start) and moment(order.utc).isBefore(end)
                # console.log "order", order
                # if order.paymentStatus is "received" or order.paymentStatus is "paidout"

                # Get Index
                if interval is "monthly"
                  intervalName = moment(order.utc).format("MMM")
                  intervalIdx = moment(order.utc).startOf('month').format("YYMM")
                  intervalStart = moment(order.utc).startOf('month')
                
                if interval is "weekly"
                  # Find start of saturday
                  time = moment(order.utc)
                  if time.day() < 6
                    time.startOf("week").subtract("d", 1).startOf("day")
                  else
                    time.endOf("week").startOf("day")
                  intervalName = time.clone().add('days', 6).format("MMM D")
                  intervalIdx = time.format("YYMMDD")
                  intervalStart = time
                  intervalEnd = time.clone().add('days', 7)

                # Add to period
                if not periods[intervalIdx]
                  periods[intervalIdx] =
                    revenue: 0
                    gross: 0
                    hrsSold: 0
                    orders: []
                    intervalIdx: intervalIdx
                    intervalName: intervalName
                    intervalStart: intervalStart
                    intervalEnd: intervalEnd

                period = periods[intervalIdx]
                period.orders.push order
                period.revenue += order.total
                period.gross += order.profit
                period.hrsSold += calcTotal [item] for item in order.lineItems
                filteredOrders.push order

            # console.log "filteredOrders", filteredOrders






            # Interate through each period. Calc more stats. Get differences.

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

            _.each periods, (period) =>

              period.customers = _.uniq(_.pluck period.orders, 'userId')
              period.customerTotal = period.customers.length
              period.hrPerCust = period.hrsSold/period.customerTotal
              period.profitPerHour = period.gross/period.hrsSold
              period.revPerHour = period.revenue/period.hrsSold
              period.margin = period.gross/period.revenue
              period.revPerCust = period.revenue/period.customerTotal
              
              period.custReturning = _.intersection(period.customers, @getCustomersBefore(period.intervalStart)).length
              period.custReturningPercent = period.custReturning/period.customerTotal


              # Add start and end dates in each interval
              @filterGrowthRequests period.intervalStart, period.intervalEnd, (data) ->   

                period.requestsNum = data.requests.length
                period.reqPerOrders = period.requestsNum/period.orders.length
                period.hrsOnAir = 0
                _.each data.calls, (item, i) -> period.hrsOnAir += item.duration

                # console.log "period.hrsOnAir", period.hrsOnAir, period.intervalName
                period.hrsAirPerHrsSold = period.hrsOnAir/period.hrsSold



                reportTotals.numPeriods++
                # reportTotals.customerTotal += period.customerTotal
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
                    phrsSold: (period.hrsSold-prevPeriod.hrsSold)/prevPeriod.hrsSold
                    pprofitPerHour: (period.profitPerHour/prevPeriod.profitPerHour)-1
                    # profit/hr
                    # prevPerHour: (period.revPerHour-prevPeriod.revPerHour)/prevPeriod.revPerHour
                    pgross: (period.gross-prevPeriod.gross)/prevPeriod.gross
                    pmargin: (period.margin-prevPeriod.margin)/prevPeriod.margin
                    prevenue: (period.revenue-prevPeriod.revenue)/prevPeriod.revenue
                    prevPerCust: (period.revPerCust/prevPeriod.revPerCust)-1
                    phrPerCust: (period.revPerCust/prevPeriod.revPerCust)-1
                    pcustomerTotal: (period.customerTotal-prevPeriod.customerTotal)/prevPeriod.customerTotal
                    pcustReturningPercent: (period.custReturningPercent/prevPeriod.custReturningPercent)-1
                    porders: (period.orders.length/prevPeriod.orders.length)-1

                    prequestsNum: (period.requestsNum/prevPeriod.requestsNum) - 1
                    preqPerOrders: (period.reqPerOrders/prevPeriod.reqPerOrders) - 1
                    phrsOnAir: (period.hrsOnAir/prevPeriod.hrsOnAir) - 1
                    phrsAirPerHrsSold: (period.hrsAirPerHrsSold/prevPeriod.hrsAirPerHrsSold) - 1


                report.push period
                prevPeriod = period


            # Final report totals
            filteredUsers = _.uniq(_.pluck filteredOrders, 'userId')

            reportTotals.customerTotal = filteredUsers.length
            reportTotals.profitPerHour = reportTotals.gross/reportTotals.hrsSold
            reportTotals.ordersNum = filteredOrders.length
            reportTotals.revPerHour = reportTotals.revenue/reportTotals.hrsSold
            reportTotals.margin = reportTotals.gross/reportTotals.revenue
            reportTotals.hrPerCust = reportTotals.hrsSold/reportTotals.customerTotal
            reportTotals.ltv = reportTotals.margin*reportTotals.revPerHour*reportTotals.hrPerCust
            reportTotals.revPerCust = reportTotals.revenue/reportTotals.customerTotal
            reportTotals.custReturning = _.intersection(filteredUsers, @getCustomersBefore(start)).length
            reportTotals.custReturningPercent = reportTotals.custReturning/reportTotals.customerTotal



            # Get requests
            # @getGrowthRequests (data) ->
            # @filterGrowthRequests start, end, (data) =>
              # console.log "data.requests", data.requests
            reportTotals.requestsNum = @growthRequests.length
            reportTotals.reqPerOrders = reportTotals.requestsNum/reportTotals.ordersNum

            reportTotals.hrsOnAir = 0
            _.each @growthRequestCalls, (item, i) -> reportTotals.hrsOnAir += item.duration
            reportTotals.hrsAirPerHrsSold = reportTotals.hrsOnAir/reportTotals.hrsSold

            
            





            # Make api calls to get requests and hrs on air

            # callsLeft = (report.length+1)
            # calcDiffs = ->
            #   if callsLeft > 1 then callsLeft-- else
            #     console.log "GET DIFF"
            #     for period, i in report
            #       if period.intervalStart and report[i + 2]?
            #         diff = report[i + 1] 
            #         periodNext = report[i + 2] 
            #         diff.prequestsNum = (periodNext.requestsNum/period.requestsNum) - 1
            #         diff.preqPerOrders = (periodNext.reqPerOrders/period.reqPerOrders) - 1
            #         diff.phrsOnAir = (periodNext.hrsOnAir/period.hrsOnAir) - 1
            #         diff.phrsAirPerHrsSold = (periodNext.hrsAirPerHrsSold/period.hrsAirPerHrsSold) - 1
            #     calcFinalDiff(report)

            # _.each report, (period, index) =>
              
            #   # Add start and end dates in each interval
            #   if period.intervalStart 
            #     if report[index + 2]?
            #       period.intervalEnd = report[index + 2].intervalStart
            #     else 
            #       period.intervalEnd = moment()

            #     @filterGrowthRequests period.intervalStart, period.intervalEnd, (data) ->

            #       period.requestsNum = data.requests.length
            #       period.reqPerOrders = period.requestsNum/period.orders.length
            #       period.hrsOnAir = 0
            #       _.each data.calls, (item, i) -> period.hrsOnAir += item.duration
            #       period.hrsAirPerHrsSold = period.hrsOnAir/period.hrsSold
                  
            #       calcDiffs()








                  


            # Calc final Week Diff

            calcFinalDiff = (report) ->

              if interval is "weekly"

                # Get current week index
                # time = moment({y: 2014, M: 5, d: 23})
                time = moment()
                if time.day() < 6
                  time.startOf("week").subtract("d", 1).startOf("day")
                else
                  time.endOf("week").startOf("day")
                curWeekIdx = time.format("YYMMDD")
                finalWeek = report[report.length - 1]

                # console.log "weeks", curWeekIdx, finalWeek.intervalIdx
                # console.log "report", report

                # If last week
                if curWeekIdx is finalWeek.intervalIdx and report.length > 2
                  

                  finalDiff = report[report.length - 2]
                  prevWeek = report[report.length - 3]
                  
                  # console.log "finalWeek", finalWeek
                  # console.log "finalDiff", finalDiff
                  # console.log "prevWeek", prevWeek


                  # Get week percentage
                  wkStart = moment()
                  if wkStart.day() < 6
                    wkStart.startOf("week").subtract("d", 1).startOf("day")
                  else
                    wkStart.endOf("week").startOf("day")
                  wkPercentage = (moment().unix()-wkStart.unix())/60/60/24/7
                  console.log "wkPercentage = #{Math.floor(wkPercentage*100)}%"

                  _.extend finalDiff,
                    intervalName: "#{Math.floor(wkPercentage*100)}%"
                    pcustomerTotal: (finalWeek.customerTotal / (prevWeek.customerTotal*wkPercentage)) - 1
                    phrsSold: (finalWeek.hrsSold / (prevWeek.hrsSold*wkPercentage)) - 1
                    prevenue: (finalWeek.revenue / (prevWeek.revenue*wkPercentage)) - 1
                    pgross: (finalWeek.gross / (prevWeek.gross*wkPercentage)) - 1
                    prequestsNum: (period.requestsNum/prevPeriod.requestsNum*wkPercentage) - 1
                    phrsOnAir: (period.hrsOnAir/prevPeriod.hrsOnAir*wkPercentage) - 1




              # Calc final Month Diff

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
                  prequestsNum: (finalMonth.requestsNum/(prevMonth.requestsNum*monthPercentage)) - 1
                  phrsOnAir: (finalMonth.hrsOnAir/(prevMonth.hrsOnAir*monthPercentage)) - 1




            calcFinalDiff(report)





            console.log "REPORT", _.sortBy(report, (m) -> m.intervalIdx).reverse()

            
            # Sort, reverse, and return
            callback {
              report: _.sortBy(report, (m) -> m.intervalIdx).reverse()
              reportTotals: reportTotals
            }
            console.timeEnd("getGrowth")
            console.groupEnd()
                       
            # return {
            #   report: _.sortBy(report, (m) -> m.intervalIdx).reverse()
            #   reportTotals: reportTotals
            # }





        getChannelMetrics: (start, end) ->
          # console.log "getChannelMetrics"
          # console.log "dates = ", start, end
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
          # console.log "getChannelMetricsSummary"
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

          # console.log "getChannelGrowth"

          weeks = $moment.getWeeksByFriday(moment().subtract("weeks", 4), moment(), 6).reverse()

          # console.log "weeks", weeks

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

          # console.log "Updating final week.."

          # Update final week diff
          _.each finalWeek.metrics.summary.tags, (tag, tagName) ->
            if tagName is '' or not prevWeek.metrics.summary.tags[tagName] then return

            # console.log "prevWeek.metrics.summary.tags[tagName] = ", prevWeek.metrics.summary.tags[tagName]

            newCount = tag.count
            oldCount = prevWeek.metrics.summary.tags[tagName].count*wkPercentage

            finalWeek.diffTags[tagName] =
              count: if oldCount is 0 then (newCount-oldCount) else (newCount/oldCount)-1

          # console.groupEnd()
          return weeks.reverse()








    apData.orders.data = _.sortBy(apData.orders.data, (o) -> moment(o.utc))
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
      console.log "updateOrderList"
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

    
    apData.orders.getGrowth 'monthly', null, null, (month2month) -> 
      console.log "month2month", month2month
      $scope.report = month2month.report
      $scope.reportTotals = month2month.reportTotals
      $scope.$apply() if not $scope.$$phase




    
    



  ]).







  # Order metrics controller

  controller("ChannelsCtrl", ['$scope', '$location', 'apData', ($scope, $location, apData) ->


    $scope.dateStart = moment().startOf("week").subtract("w", 2).toDate()
    $scope.dateEnd = moment().endOf('week').toDate()

    $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd)

    updateRange = ->
      return if not $scope.dateStart or not $scope.dateEnd
      $scope.metrics = apData.orders.getChannelMetrics($scope.dateStart, $scope.dateEnd)

    # Watch date updates
    $scope.$watch "dateStart", () -> updateRange()
    $scope.$watch "dateEnd", () -> updateRange()


  ]).






  # Weekly Summary controller

  controller("WeeklyCtrl", ['$scope', '$location', '$moment', 'apData', ($scope, $location, $moment, apData ) ->


    # Overall Growth
    $scope.dateStart = moment().subtract('w', 4).toDate()
    $scope.dateEnd = moment().toDate()

    updateRange = () ->
      return if not $scope.dateStart or not $scope.dateEnd
      apData.orders.getGrowth 'weekly', moment($scope.dateStart), moment($scope.dateEnd), (week2week) ->
        $scope.report = week2week.report
        $scope.reportTotals = week2week.reportTotals
        $scope.$apply() if not $scope.$$phase


    # Watch date ranges
    first = true
    $scope.$watch "dateStart", () -> 
      if first then return first = false
      updateRange()
    $scope.$watch "dateEnd", () -> updateRange()






    # Channel Growth
    $scope.channelGrowth = apData.orders.getChannelGrowth(moment().subtract('weeks', 7))


  ])












