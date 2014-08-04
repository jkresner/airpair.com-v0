
# Filter - numFloor

angular.module('AirpairAdmin').filter('numFloor', () ->
  (input) -> if typeof input is 'number' then Math.floor(input) else input
)





