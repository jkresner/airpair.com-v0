
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


)
