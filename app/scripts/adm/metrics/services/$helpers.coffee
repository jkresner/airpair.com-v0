
# Helpers Service
#----------------------------------------------

angular.module('AirpairAdmin').factory('$helpers', () ->
  $helpers =
    calcDiff: (oldNum, newNum, percentage) ->

      if percentage
        if oldNum is 0
          1
        if newNum is 0 and oldNum is 0
          0
        else
          (newNum / (oldNum * percentage) - 1)

      else
        if oldNum is newNum then return 0
        if oldNum is 0
          num = (newNum - oldNum)
        else
          num = (newNum - oldNum) / oldNum
        return num

    calcConversion: (first, second) ->
      if first is 0 then return 0
      return second/first or 0

    search: (list, searchString) ->
      filteredList = []
      for item in list
        matchList = []
        matchList.push c for c in item.campaigns if item.campaigns
        matchList.push t.name for t in item.marketingTags if item.marketingTags
        for str in matchList
          if str.indexOf(searchString) > -1
            filteredList.push item
            break
      return filteredList


    # Create a list of returning customers in orders.
    calcRepeatCustomers: (data, callback) ->
      customers = {}
      for order in data
        if not customers[order.userId]
          customers[order.userId] =
            orderDates: []
        customers[order.userId].orderDates.push order.utc
      # Delete non returning customers
      _.each customers, (cust, id) -> if cust.orderDates.length < 2 then delete customers[id]
      if callback then callback(customers)
      return customers

)
