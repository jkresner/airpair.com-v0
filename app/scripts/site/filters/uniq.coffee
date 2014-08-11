  ###
  Filters out all duplicate items from an array by checking the specified key
  @param [key] {string} the name of the attribute of each object to compare for uniqueness
  if the key is empty, the entire object will be compared
  if the key === false then no filtering will be performed
  @return {array}
  ###
  angular.module("ngAirPair").filter "uniq", ->
    (items, filterOn) ->
      return items if filterOn is false
      if (filterOn or angular.isUndefined(filterOn)) and angular.isArray(items)
        hashCheck = {}
        newItems = []
        extractValueToCompare = (item) ->
          if angular.isObject(item) and angular.isString(filterOn)
            item[filterOn]
          else
            item

        angular.forEach items, (item) ->
          valueToCheck = undefined
          isDuplicate = false
          i = 0

          while i < newItems.length
            if angular.equals(extractValueToCompare(newItems[i]), extractValueToCompare(item))
              isDuplicate = true
              break
            i++
          newItems.push item  unless isDuplicate
          return

        items = newItems
      items
