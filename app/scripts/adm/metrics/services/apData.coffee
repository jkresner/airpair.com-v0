
calcExpertCredit = require 'lib/mix/calcExpertCredit'
ObjectId2Date = require 'lib/mix/objectId2Date'

{calcTotal, calcRedeemed, calcCompleted} = calcExpertCredit




# Airpair Data Service
#----------------------------------------------
angular.module('AirpairAdmin').factory('apData', ['$moment', '$filter', '$http', '$helpers', '$mixpanel', ($moment, $filter, $http, $helpers, $mixpanel) ->

  window.apData =





    # ORDERS
    #----------------------------------------------

    orders:
      data: window.pageData.orders
      get: () ->
        @data

      filter: (start, end, searchText, dataSet = @data) ->

        visibleOrders = []
        for order in dataSet
          if @isWithinDate(order, start, end)
            visibleOrders.push order
        if searchText
          visibleOrders = $filter('filter')(visibleOrders, searchText)


        data = {
          orders: visibleOrders
          summary: @calcSummary(visibleOrders)
        }

        return data

      filterByTags: (start, end, searchText, newOnly, dataSet = @data) ->

        visibleOrders = []
        for order in dataSet
          if @isWithinDate(order, start, end)
            if order.marketingTags[0]?.name is "airconf"
              # console.log "airconf", order
            else
              if newOnly
                if not order.isRepeat then visibleOrders.push order
              else
                visibleOrders.push order

        if searchText
          visibleOrders = $helpers.search visibleOrders, searchText


        data = {
          orders: visibleOrders
          summary: @calcSummary(visibleOrders)
        }

        return data


      isWithinDate: (order, start, end) ->
        if moment.isMoment(start) then start = start.toDate()
        if moment.isMoment(end) then end = end.toDate()
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

        # TYPES = []

        for order in orders

          summary.totalRevenue += order.total
          summary.totalProfit += order.profit

          for item in order.lineItems

            # TYPES.push item.type


            # if _.isNaN(calcRedeemed([item])) then console.log "NAN calcRedeemed item", item, order
            if item.type in ['opensource', 'private', 'nda']

              summary.totalRedeemed += calcRedeemed [item]
              summary.totalCompleted += calcCompleted [item]
              summary.totalHours += calcTotal [item]

              # if not _.isNumber(calcCompleted [item]) then console.log "NAN calcCompleted item", item
              # if not _.isNumber(calcTotal [item]) then console.log "NAN calcTotal item", item
              # console.log "SAME?", (item.total == calcTotal([item])), item.total, calcTotal([item])
              # if item.total isnt calcTotal([item])
                # console.log "order === ", order
              # summary.totalHours += item.total


              summary.experts.push item.suggestion.expert._id

        summary.orderCount = orders.length
        summary.customerCount = _.uniq(_.pluck orders, 'userId').length
        summary.requestCount = _.uniq(_.pluck orders, 'requestId').length
        summary.expertCount = _.uniq(summary.experts).length



        # console.log "TYPES", _.groupBy TYPES, (type) -> type

        # console.log "SUMMARY", summary
        return summary




      calcCredits: ->
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



      # Create a list of returning customers in orders.
      calcRepeatCustomers: (callback) ->
        if not @repeatCustomers
          console.time("calcRepeatCustomers")
          customers = {}

          for order in @data
            if not customers[order.userId]
              customers[order.userId] =
                orderDates: []
            customers[order.userId].orderDates.push order.utc

          # Save for later
          @customers = _.clone customers
          _.each customers, (cust, id) -> if cust.orderDates.length < 2 then delete customers[id]
          console.timeEnd("calcRepeatCustomers")
          @repeatCustomers = customers

        if callback then callback(@repeatCustomers)
        return @repeatCustomers


      # Check how many customers in a list are repeat
      findRepeatCustomers: (customers, start) ->
        count = 0
        for cust in customers
          if @repeatCustomers[cust]
            before = false
            for date in @repeatCustomers[cust].orderDates
              if moment(date).isBefore(start) then before = true
            if before then count++
        return count


      # Add an isRepeat val on each order if the customer is a repeat
      markRepeatOrders: ->
        if @repeatMarked then return @data
        for order in @data
          if @repeatCustomers[order.userId]
            order.isRepeat = true
        @repeatMarked = true
        return @data



      getGrowthRequests: (start, end, callback = ->) ->

        startDate = start.format('YYYY-MM-DD')
        endDate = end.clone().add("d", 1).format('YYYY-MM-DD')

        count = 0
        api = {}
        # Get requests
        $http.get("/api/admin/requests/#{startDate}/#{endDate}").success (data, status, headers, config) =>
          console.log "API requests", data.length
          @growthRequests = api.requests = data
          count++
          if count is 2 then callback(api)
        # Hrs on air
        $http.get("/api/admin/requests/calls/#{startDate}/#{endDate}").success (data, status, headers, config) =>
          console.log "API calls", data.length
          @growthRequestCalls = api.calls = data
          count++
          if count is 2 then callback(api)
        # else
        #   callback(requests: @growthRequests, calls: @growthRequestCalls)



      filterGrowthRequests: (start, end, callback) ->

        # start = moment("2014-07-12")
        # end   = moment("2014-07-19")

        # console.log "filterGrowthRequests", start.toDate(), "–", end.toDate()


        data =
          requests: @growthRequests
          calls: @growthRequestCalls


        filteredRequests = []
        filteredCalls = []

        for val, i in data.requests
          date = moment ObjectId2Date(val._id)
          # console.log "date", date.toDate(), date.isAfter(start), date.isBefore(end), end.toDate()
          if date.isAfter(start) and date.isBefore(end)
            filteredRequests.push val


        for val, i in data.calls
          date = moment val.datetime
          if date.isAfter(start) and date.isBefore(end)
            filteredCalls.push val
            # console.log "calls date", date.isAfter(start), date.isBefore(end), date.toDate()


        filtered =  {
          requests: filteredRequests
          calls: filteredCalls
        }

        # console.log "filtered = ", filtered
        callback filtered




      getGrowth: (interval = 'monthly', start = moment(@data[0].utc).subtract("d", 1), end = moment(), callback) ->

        console.group "getGrowth #{interval} #{start.toDate()} – #{end.toDate()}"


        console.time("Total getGrowth")

        # @growthStart = start
        # @growthEnd = end

        @calcRepeatCustomers()

        # Get API requests first
        console.time("api calls")

        @getGrowthRequests start, end, =>
          console.timeEnd("api calls")

          console.log "... api calls completed. Crunching data.."

          console.time("dataCrunching")


          # Group orders by period. Calculate revenue, gross, and hrs sold.
          console.time("data - 1 - group periods")

          periods = {}
          filteredOrders = []

          for order in @data

            if moment(order.utc).isAfter(start) and moment(order.utc).isBefore(end)

              # Get Index
              if interval is "monthly"
                intervalName = moment(order.utc).format("MMM")
                intervalIdx = moment(order.utc).startOf('month').format("YYMM")
                intervalStart = moment(order.utc).startOf('month')
                intervalEnd = moment(order.utc).endOf('month')

              if interval is "weekly"
                # Find start of saturday
                time = moment(order.utc)
                if time.day() < 6
                  time.startOf("week").subtract("d", 1).startOf("day")
                else
                  time.endOf("week").startOf("day")
                intervalName = time.clone().add('days', 6).format("MM DD")
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



          console.timeEnd("data - 1 - group periods")




          console.time("data - 2 - interate periods")
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

            console.time("data - one period")
            period.customers = _.uniq(_.pluck period.orders, 'userId')
            period.customerTotal = period.customers.length
            period.hrPerCust = period.hrsSold/period.customerTotal
            period.profitPerHour = period.gross/period.hrsSold
            period.revPerHour = period.revenue/period.hrsSold
            period.margin = period.gross/period.revenue
            period.revPerCust = period.revenue/period.customerTotal
            period.ltv = period.margin*period.revPerHour*period.hrPerCust
            period.ordersNum = period.orders.length

            period.custReturning = @findRepeatCustomers(period.customers, period.intervalStart)

            period.custReturningPercent = period.custReturning/period.customerTotal


            # Add start and end dates in each interval
            @filterGrowthRequests period.intervalStart, period.intervalEnd, (data) ->



              period.requestsNum = data.requests.length
              period.ordersPerReq = period.ordersNum/period.requestsNum

              period.hrsOnAir = 0
              _.each data.calls, (item, i) -> period.hrsOnAir += item.duration
              period.hrsAirPerHrsSold = period.hrsOnAir/period.hrsSold



              reportTotals.numPeriods++
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

                  pltv: $helpers.calcDiff( prevPeriod.ltv, period.ltv )
                  pgross: $helpers.calcDiff( prevPeriod.gross, period.gross )
                  pmargin: $helpers.calcDiff( prevPeriod.margin, period.margin )
                  pprofitPerHour: $helpers.calcDiff( prevPeriod.profitPerHour, period.profitPerHour )
                  phrsOnAir: $helpers.calcDiff( prevPeriod.hrsOnAir, period.hrsOnAir )
                  phrsAirPerHrsSold: $helpers.calcDiff( prevPeriod.hrsAirPerHrsSold, period.hrsAirPerHrsSold )
                  phrsSold: $helpers.calcDiff( prevPeriod.hrsSold, period.hrsSold )
                  prevPerHour: $helpers.calcDiff( prevPeriod.revPerHour, period.revPerHour )
                  prevenue: $helpers.calcDiff( prevPeriod.revenue, period.revenue )
                  prevPerCust: $helpers.calcDiff( prevPeriod.revPerCust, period.revPerCust )
                  pcustomerTotal: $helpers.calcDiff( prevPeriod.customerTotal, period.customerTotal )
                  phrPerCust: $helpers.calcDiff( prevPeriod.revPerCust, period.revPerCust )
                  pcustReturningPercent: $helpers.calcDiff( prevPeriod.custReturningPercent, period.custReturningPercent )
                  porders: $helpers.calcDiff( prevPeriod.ordersNum, period.ordersNum )
                  pordersPerReq: $helpers.calcDiff( prevPeriod.ordersPerReq, period.ordersPerReq )
                  prequestsNum: $helpers.calcDiff( prevPeriod.requestsNum, period.requestsNum )


              report.push period
              prevPeriod = period
              console.timeEnd("data - one period")



          # Final report totals

          console.time("data - finals")
          filteredUsers = _.uniq(_.pluck filteredOrders, 'userId')

          reportTotals.customerTotal = filteredUsers.length
          reportTotals.profitPerHour = reportTotals.gross/reportTotals.hrsSold
          reportTotals.ordersNum = filteredOrders.length
          reportTotals.revPerHour = reportTotals.revenue/reportTotals.hrsSold
          reportTotals.margin = reportTotals.gross/reportTotals.revenue
          reportTotals.hrPerCust = reportTotals.hrsSold/reportTotals.customerTotal
          reportTotals.ltv = reportTotals.margin*reportTotals.revPerHour*reportTotals.hrPerCust
          reportTotals.revPerCust = reportTotals.revenue/reportTotals.customerTotal
          reportTotals.custReturning = @findRepeatCustomers(filteredUsers, start)
          reportTotals.custReturningPercent = reportTotals.custReturning/reportTotals.customerTotal


          # Get requests
          reportTotals.requestsNum = @growthRequests.length
          reportTotals.ordersPerReq = reportTotals.ordersNum/reportTotals.requestsNum

          reportTotals.hrsOnAir = 0
          _.each @growthRequestCalls, (item, i) -> reportTotals.hrsOnAir += item.duration
          reportTotals.hrsAirPerHrsSold = reportTotals.hrsOnAir/reportTotals.hrsSold
          console.timeEnd("data - finals")

          console.timeEnd("data - 2 - interate periods")



          console.time("data - 3 - final diff")


          # Calcuate Final Projections

          calcFinalDiff = (report) ->


            # Weekly Projections

            if interval is "weekly"

              # Get current week index
              time = moment()
              if time.day() < 6
                time.startOf("week").subtract("d", 1).startOf("day")
              else
                time.endOf("week").startOf("day")
              curWeekIdx = time.format("YYMMDD")
              finalWeek = report[report.length - 1]

              return if not finalWeek

              # If last week
              if curWeekIdx is finalWeek.intervalIdx and report.length > 2


                finalDiff = report[report.length - 2]
                prevWeek = report[report.length - 3]


                # Get week percentage
                wkStart = moment()
                if wkStart.day() < 6
                  wkStart.startOf("week").subtract("d", 1).startOf("day")
                else
                  wkStart.endOf("week").startOf("day")
                wkPercentage = (moment().unix()-wkStart.unix())/60/60/24/7

                console.log "wkPercentage = #{wkPercentage*100}%"

                # console.log "finalDiff", finalDiff

                # console.log "prequestsNum = #{finalWeek.requestsNum}/(#{prevWeek.requestsNum}*#{wkPercentage}) - 1 = #{(finalWeek.requestsNum/(prevWeek.requestsNum*wkPercentage)) - 1}"

                _.extend finalDiff,
                  intervalName: "#{Math.floor(wkPercentage*100)}%"

                  pgross: $helpers.calcDiff(prevWeek.gross, finalWeek.gross, wkPercentage)
                  phrsOnAir: $helpers.calcDiff( prevWeek.hrsOnAir, finalWeek.hrsOnAir, wkPercentage )
                  phrsSold: $helpers.calcDiff( prevWeek.hrsSold, finalWeek.hrsSold, wkPercentage )
                  prevenue: $helpers.calcDiff( prevWeek.revenue, finalWeek.revenue, wkPercentage )
                  pcustomerTotal: $helpers.calcDiff( prevWeek.customerTotal, finalWeek.customerTotal, wkPercentage )
                  porders: $helpers.calcDiff( prevWeek.ordersNum, finalWeek.ordersNum, wkPercentage )
                  prequestsNum: $helpers.calcDiff( prevWeek.requestsNum, finalWeek.requestsNum, wkPercentage )




            # Monthly Projections

            if interval is "monthly"

              finalMonth = report[report.length - 1]
              finalDiff = report[report.length - 2]
              prevMonth = report[report.length - 3]

              monthPercentage = (moment().unix()-moment().startOf('month').unix()) / (moment().endOf('month').unix()-moment().startOf('month').unix())
              console.log "monthPercentage", monthPercentage

              _.extend finalDiff,
                intervalName: "#{Math.floor(monthPercentage*100)}%"

                pgross: $helpers.calcDiff(prevMonth.gross, finalMonth.gross, monthPercentage)
                phrsOnAir: $helpers.calcDiff( prevMonth.hrsOnAir, finalMonth.hrsOnAir, monthPercentage )
                phrsSold: $helpers.calcDiff( prevMonth.hrsSold, finalMonth.hrsSold, monthPercentage )
                prevenue: $helpers.calcDiff( prevMonth.revenue, finalMonth.revenue, monthPercentage )
                pcustomerTotal: $helpers.calcDiff( prevMonth.customerTotal, finalMonth.customerTotal, monthPercentage )
                porders: $helpers.calcDiff( prevMonth.ordersNum, finalMonth.ordersNum, monthPercentage )
                prequestsNum: $helpers.calcDiff( prevMonth.requestsNum, finalMonth.requestsNum, monthPercentage )




          calcFinalDiff(report)



          console.timeEnd("data - 3 - final diff")


          console.log "REPORT", _.sortBy(report, (m) -> m.intervalIdx).reverse()


          # Sort, reverse, and return
          callback {
            report: _.sortBy(report, (m) -> m.intervalIdx).reverse()
            reportTotals: reportTotals
          }
          console.timeEnd("dataCrunching")

          console.timeEnd("Total getGrowth")
          console.groupEnd()






      getChannelMetrics: (start, end, type = 'orders') ->
        console.log "getChannelMetrics ==", type
        end = moment(end).endOf("day")

        @calcRepeatCustomers()



        cleanRequests = ->
          for req in dataSet
            req.utc = ObjectId2Date req._id



        if type is 'orders'
          metrics = @metricsOrders
          metricsRepeated = @metricsOrdersRepeated
          dataSet = apData.orders.data
        else
          metrics = @metricsRequests
          metricsRepeated = @metricsRequestsRepeated
          dataSet = apData.orders.growthRequests
          cleanRequests()




        # Clean up the orders/requests into metics

        cleanMetrics = () =>
          console.log "cleanMetrics #{type}"
          if not metrics
            console.log "calc metrics"
            metricsRepeated = []
            metrics = []
            TAGS = []
            console.log "dataSet #{type}", dataSet
            for order in dataSet
              # console.log "request"
              metric =
                budget: order.budget or 0
                utc: order.utc
                name: order.company.contacts[0].fullName
                userId: order.company.contacts[0]._id
                tags: {}
                total: order.total
                campaigns: []
                requestId: order.requestId or order._id
                isRepeat: if @findRepeatCustomers([order.userId], order.utc) > 0 then true else false
                hasTags: false
                tags:
                  ad: {total:0, revenue: 0}
                  affiliate: {total:0, revenue: 0}
                  direct: {total:0, revenue: 0}
                  incubator: {total:0, revenue: 0}
                  newsletterairpair: {total:0, revenue: 0}
                  press: {total:0, revenue: 0}
                  event: {total:0, revenue: 0}
                  seo: {total:0, revenue: 0}
                  social: {total:0, revenue: 0}
                  wordofmouth: {total:0, revenue: 0}
                  untracked: {total:0, revenue: 0}
                  # stackoverflowads: {total:0, revenue: 0}

              _.each order.marketingTags, (tag) ->
                # console.log "tag.group", tag.group
                TAGS.push tag.group
                channelTags = _.where order.marketingTags, { type: "channel" }
                tagName = tag.group.replace('-', '')
                if tag.type is "channel"
                  if tag.name is "w-o-mouth"
                    tagName = "wordofmouth"
                  # tags.push tagName
                  metric.tags[tagName] = tag
                  metric.tags[tagName].total = metric.total/channelTags.length
                  metric.tags[tagName].budget = metric.budget
                  metric.hasTags = true
                if tag.type is "campaign"
                  metric.campaigns.push(tag.name)
                  metric.hasTags = true

              metricsRepeated.push metric if metric.isRepeat
              metrics.push metric
            console.log "tag.groups", _.groupBy TAGS, (num) -> num

            _(metrics).reverse()
            _(metricsRepeated).reverse()

          if type is 'orders'
            @metricsOrders = metrics
            @metricsOrdersRepeated = metricsRepeated
          else
            @metricsRequests = metrics
            @metricsRequestsRepeated = metricsRepeated


            # return filterMetrics start, end
            # return {
            #   metrics: metrics
            #   metricsRepeated: metricsRepeated
            # }
          # else
          return filterMetrics start, end
            # return {
            #   metrics: metrics
            #   metricsRepeated: metricsRepeated
            # }


        filterMetrics = (start, end) =>
          # console.log "filterMetrics", metrics
          # Filter by date
          if start and end
            metricsFiltered = []
            metricsRepeatFiltered = []
            for order in metrics
              date = new Date(order.utc)
              if date >= start and date <= end
                metricsFiltered.push order
            for order in metricsRepeated
              date = new Date(order.utc)
              if date >= start and date <= end
                metricsRepeatFiltered.push order

            data = {
              orders: metricsFiltered
              summary: @getChannelMetricsSummary(metricsFiltered)
              repeatSummary: @getChannelMetricsSummary(metricsRepeatFiltered)
              metricsRepeated: metricsRepeatFiltered
            }
            # console.log "filterMetrics COMPLETE", data
            return data

        return cleanMetrics()




      getChannelMetricsSummary: (metrics) ->
        # console.log "getChannelMetricsSummary", metrics
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

        # console.log "metricsSummary", summary
        metricsSummary = summary


      getChannelGrowth: (start = moment(@data[0].utc), end = moment(), type = "orders") ->


        weeks = $moment.getWeeksByFriday(start, end).reverse()

        console.log "getChannelGrowth WEEKS", weeks, start.toDate(), end.toDate()


        # Get Metrics for each week
        prev = null
        for week in weeks
          week.metrics = @getChannelMetrics(week.start, week.end, type)
          # console.log "week.metrics ", week.metrics

          # Calculate the percentage share for repeat customers
          week.metrics.repeatSummary.numOrdersShare = week.metrics.repeatSummary.numOrders/week.metrics.summary.numOrders or 0
          _.each week.metrics.repeatSummary.tags, (tag, tagName) ->
            tag.share = tag.count/week.metrics.summary.tags[tagName].count



          # Get difference between weeks
          if prev

            # Get difference for normal tags
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
            # get total diff
            week.diffTags.TOTAL = (week.metrics.summary.numOrders/prev.metrics.summary.numOrders)-1

            # Get difference for repeat customer tags
            week.diffTagsRepeat = {}
            _.each prev.metrics.repeatSummary.tags, (tag, tagName) ->
              if tagName is '' then return
              if not week.metrics.repeatSummary.tags[tagName]
                week.metrics.repeatSummary.tags[tagName] =
                  count: 0
              newCount = week.metrics.repeatSummary.tags[tagName].share or 0 #/week.metrics.summary.tags[tagName].count
              oldCount = tag.share or 0 #/prev.metrics.summary.tags[tagName].count
              week.diffTagsRepeat[tagName] =
                count: $helpers.calcDiff oldCount, newCount
            # get total diff
            week.diffTagsRepeat.TOTAL = $helpers.calcDiff prev.metrics.repeatSummary.numOrders, week.metrics.repeatSummary.numOrders

          prev = week



        # Calc Projections

        # Get current week index
        time = moment()
        if time.day() < 6
          time.startOf("week").subtract("d", 1).startOf("day")
        else
          time.endOf("week").startOf("day")
        curWeekIdx = time.format("YYMMDD")

        # Get last two weeks
        finalWeek = weeks[weeks.length - 1]
        prevWeek = weeks[weeks.length - 2]

        return if not finalWeek


        # If the current week is the final week, calculate projections
        if curWeekIdx is finalWeek.index

          # get percentage through week
          wkStart = moment()
          if wkStart.day() < 6
            wkStart.startOf("week").subtract("d", 1).startOf("day")
          else
            wkStart.endOf("week").startOf("day")
          wkPercentage = (moment().unix()-wkStart.unix())/60/60/24/7

          # Update final week diff
          if prevWeek
            _.each finalWeek.metrics.summary.tags, (tag, tagName) ->
              if tagName is '' or not prevWeek.metrics.summary.tags[tagName] then return
              newCount = tag.count or 0
              oldCount = prevWeek.metrics.summary.tags[tagName].count or 0
              finalWeek.diffTags[tagName] =
                count: $helpers.calcDiff oldCount, newCount, wkPercentage
            finalWeek.diffTags.TOTAL = $helpers.calcDiff prevWeek.metrics.summary.numOrders, finalWeek.metrics.summary.numOrders, wkPercentage
            finalWeek.diffTags.percentage = "#{Math.floor(wkPercentage*100)}%"

            # diff for repeats
            _.each finalWeek.metrics.repeatSummary.tags, (tag, tagName) ->
              if tagName is '' or not prevWeek.metrics.repeatSummary.tags[tagName] then return
              newCount = tag.share or 0
              oldCount = prevWeek.metrics.repeatSummary.tags[tagName].share or 0
              finalWeek.diffTagsRepeat[tagName] =
                count: $helpers.calcDiff oldCount, newCount, wkPercentage
              finalWeek.diffTagsRepeat.TOTAL = $helpers.calcDiff prevWeek.metrics.repeatSummary.numOrdersShare, finalWeek.metrics.repeatSummary.numOrdersShare, wkPercentage
              # console.log "final week #{tagName} - #{oldCount} to #{newCount} ", finalWeek.diffTagsRepeat[tagName].count


        return weeks.reverse()





      getChannelGrowthSummary: (weeks) ->

        summary =
          numOrders: 0
          revenueTotal: 0
          tags: {}

        repeatSummary =
          numOrders: 0
          revenueTotal: 0
          tags: {}

        for week in weeks
          # Calc summary
          summary.numOrders += week.metrics.summary.numOrders
          summary.revenueTotal += week.metrics.summary.revenueTotal
          _.each week.metrics.summary.tags, (tag, key) ->
            if not summary.tags[key]
              summary.tags[key] =
               count: 0
               revenue: 0
            summary.tags[key].count += tag.count
            summary.tags[key].revenue += tag.revenue
          # Calc repeat summary
          repeatSummary.numOrders += week.metrics.repeatSummary.numOrders
          repeatSummary.revenueTotal += week.metrics.repeatSummary.revenueTotal
          _.each week.metrics.repeatSummary.tags, (tag, key) ->
            if not repeatSummary.tags[key]
              repeatSummary.tags[key] =
               count: 0
               revenue: 0
            repeatSummary.tags[key].count += tag.count
            repeatSummary.tags[key].revenue += tag.revenue

        return {
          summary: summary
          repeatSummary: repeatSummary
        }






    # REQUESTS
    #
    # Get all requests to client and then filter
    #----------------------------------------------
    requests:

      load: (start, end, callback) ->
        startDate = start.format('YYYY-MM-DD')
        endDate = end.clone().add("d", 1).format('YYYY-MM-DD')
        api = {}

        # Get requests
        $http.get("/api/admin/requests/#{startDate}/#{endDate}").success (data, status, headers, config) =>
          console.log "API requests", data.length
          @dataRequests = api.requests = data
          callback(api)


      loadAll: (callback) ->
        if not @dataRequests
          @load moment("2013-05-01"), moment(), callback
        else
          callback()


      filter: (start, end, searchString, newOnly, callback) ->
        filteredRequests = []
        for item in @dataRequests
          date = moment ObjectId2Date(item._id)
          if date.isAfter(start) and date.isBefore(end)
            if newOnly
              if not item.isRepeat then filteredRequests.push item
            else
              filteredRequests.push item
        if searchString? and searchString isnt ''
          filteredRequests = $helpers.search filteredRequests, searchString
        filtered =
          requests: filteredRequests
        if callback? then callback filtered
        return filtered


      isWithinDate: (item, start, end) ->
        if item.utc?
          date = moment(item.utc)
        else
          date = moment ObjectId2Date(item._id)
        return date.isAfter(start) and date.isBefore(end)


      getRepeats: (callback) ->
        if not @repeatCustomers
          @repeatCustomers = $helpers.calcRepeatCustomers @dataRequests
        if callback then callback(@repeatCustomers)
        return @repeatCustomers


      # Add an isRepeat val on each order if the customer is a repeat
      markRepeats: ->
        if @repeatMarked then return @dataRequests
        for request in @dataRequests
          if @repeatCustomers[request.userId]
            request.isRepeat = true
        @repeatMarked = true
        return @data








    # Ad Metrics
    #----------------------------------------------

    ads:


      getAdData: (weeks, start, end, searchString, callback) ->

        dayTotal = (channels) ->
          totals =
            imps: 0
            clicks: 0
          if not channels then return totals
          if not searchString
            _.each channels, (campaign) ->
              _.each campaign, (nums) ->
                totals.imps += nums.imps
                totals.clicks += nums.clicks
          else
            matched = {}
            _.each channels, (campaigns, channelName) ->
              if channelName.indexOf(searchString) > -1
                _.extend matched, campaigns
              else
                _.each campaigns, (nums, campaignName) ->
                  if campaignName.indexOf(searchString) > -1
                    matched[campaignName] = nums
            _.each matched, (nums) ->
              totals.imps += nums.imps
              totals.clicks += nums.clicks

          return totals


        $fb = new Firebase 'https://airpair-admin.firebaseio.com/ads'

        $fb.on 'value', (snap) ->
          console.log "value", snap.val()

          adData = snap.val()

          for week in weeks
            week.data.summary.numImps = 0
            week.data.summary.numClicks = 0
            for day in week.days
              date = day.start.format 'YYYY-MM-DD'
              dayNums = dayTotal adData[date]
              day.summary.numImps = dayNums.imps
              day.summary.numClicks = dayNums.clicks

              week.data.summary.numImps += dayNums.imps
              week.data.summary.numClicks += dayNums.clicks
              _.extend day.summary,
                conImpsToClicks: $helpers.calcConversion day.summary.numImps, day.summary.numClicks
                conClicksToViews: $helpers.calcConversion day.summary.numClicks, day.summary.numViews
                conImpsToReqs: $helpers.calcConversion day.summary.numImps, day.summary.numRequests
            _.extend week.data.summary,
              conImpsToClicks: $helpers.calcConversion week.data.summary.numImps, week.data.summary.numClicks
              conClicksToViews: $helpers.calcConversion week.data.summary.numClicks, week.data.summary.numViews
              conImpsToReqs: $helpers.calcConversion week.data.summary.numImps, week.data.summary.numRequests


          callback()








      mixpanelWeeks: (weeks, start, end, searchString, callback) ->

        dayTotal = (dayStr, data) ->
          numViews = 0
          if not searchString
            _.each data.campaign.values, (campaign, campaignName) ->
              numViews += campaign[dayStr] or 0
            return numViews
          else
            matched =
              campaign: []
              channel: []
            _.each data.campaign.values, (campaignDays, campaignName) ->
              if campaignName.indexOf(searchString) > -1
                matched.campaign.push campaignName
            _.each data.channel.values, (channel, channelName) ->
              if channelName.indexOf(searchString) > -1
                matched.channel.push channelName
            type = if matched.campaign.length > matched.channel.length then 'campaign' else 'channel'
            # console.info "matched #{type}", matched
            matches = matched[type]
            for matchedName in matches
              views = data[type].values[matchedName][dayStr]
              numViews += views or 0
            return numViews



        processData = (data) ->
          for week in weeks
            week.data.summary.numViews = 0
            for day in week.days
              day.summary.numViews = dayTotal day.start.format('YYYY-MM-DD'), data
              week.data.summary.numViews += day.summary.numViews
              _.extend day.summary,
                conViewsToRequests: $helpers.calcConversion day.summary.numViews, day.summary.numRequests
            _.extend week.data.summary,
              conViewsToRequests: $helpers.calcConversion week.data.summary.numViews, week.data.summary.numRequests
          callback()

        # Get all data within date range
        $mixpanel.api.segmentation
          from_date: start.format('YYYY-MM-DD')
          to_date: end.format('YYYY-MM-DD')
          event: "view"
          on: 'properties["utm_campaign"]'
        , (campaignData) ->

          console.log "mixpanel campaigns", campaignData

          $mixpanel.api.segmentation
            from_date: start.format('YYYY-MM-DD')
            to_date: end.format('YYYY-MM-DD')
            event: "view"
            on: 'properties["utm_source"]'
          , (channelData) ->
            console.log "mixpanel channels", channelData

            processData {
              campaign: campaignData.data
              channel: channelData.data
            }




      # Get Daily Metrics
      daily: (start, end = moment(), searchString, newOnly, callback) ->

        # Method to Calc week summary
        calcWeek = (week) ->
          week.data = apData.orders.filterByTags week.start, week.end, searchString, newOnly
          _.extend week.data, apData.requests.filter week.start, week.end, searchString, newOnly

          _.extend week.data.summary,
            numOrders: week.data.orders.length
            numRequests: week.data.requests.length
            numRevenue: week.data.summary.totalRevenue

          _.extend week.data.summary,
            conRequestsToOrders: $helpers.calcConversion week.data.summary.numRequests, week.data.summary.numOrders
            conOrdersToRevenue: $helpers.calcConversion week.data.summary.numOrders, week.data.summary.numRevenue

          week.days = $moment.daysOfWeek moment(week.start)


        # Method to calc day summary
        calcDay = (day, week) ->

          # Orders
          day.orders = []
          for order in week.data.orders
            if apData.orders.isWithinDate(order, day.start, day.end)
              day.orders.push order
          day.ordersSummary = apData.orders.calcSummary day.orders

          # Requests
          day.requests = []
          for request in week.data.requests
            if apData.requests.isWithinDate(request, day.start, day.end)
              day.requests.push request

          # Calc day summary
          day.summary =
            numOrders: if day.orders? then day.orders.length else 0
            numRequests: if day.requests? then day.requests.length else 0
            numRevenue: day.ordersSummary.totalRevenue

          _.extend day.summary,
            conRequestsToOrders: $helpers.calcConversion day.summary.numRequests, day.summary.numOrders
            conOrdersToRevenue: $helpers.calcConversion day.summary.numOrders, day.summary.numRevenue


        weeks = $moment.getWeeksByFriday(start, end)


        # Start crunching ---
        apData.requests.loadAll =>
          if newOnly
            apData.orders.calcRepeatCustomers -> apData.orders.markRepeatOrders()
            apData.requests.getRepeats -> apData.requests.markRepeats()
          # Calc summary for week
          for week in weeks
            calcWeek week
            # Calc summary for day
            for day in week.days
              calcDay day, week
          # Get mixpanel data
          @mixpanelWeeks weeks, start, end, searchString, callback
          @getAdData weeks, start, end, searchString, callback







        # Return weeks now, update as more data is loaded and crunched
        return weeks










  apData.orders.data = _.sortBy(apData.orders.data, (o) -> moment(o.utc))
  apData.orders.calcCredits()


  console.log "apData", apData


  return apData

])





