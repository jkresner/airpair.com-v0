ngExpert = (Expert) ->
  currentExpert = Expert.get('me').$object
  currentExpert

angular
  .module('ngAirPair')
  .factory('CurrentExpert', ['Expert', ngExpert])
