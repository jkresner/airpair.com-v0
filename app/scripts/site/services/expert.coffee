ngExpert = ($rootScope, Restangular) ->
  get: ->
    unless @called?
      @called = true
      Restangular.one('experts', 'me').get().then (expert) ->
        $rootScope.expert = expert
        $rootScope.$broadcast('event:expert-fetched')

angular
  .module('ngAirPair')
  .factory('Expert', ['$rootScope', 'Restangular', ngExpert])
