angular
  .module('ngAirPair')
  .filter('reverse', ->
    toArray = (list) ->
      out = []
      if( list )
        if angular.isArray(list)
          out = list
        else if typeof list is 'object'
          for k in list
            if list.hasOwnProperty(k)
              out.push(list[k])
          return out

    (items) ->
      toArray(items).slice().reverse()
  )
