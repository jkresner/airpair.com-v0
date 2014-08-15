ngTag = ($rootScope, Restangular) ->
  all: ->
    unless @called?
      @called = true
      Restangular.all('tags').getList().then (tags) ->
        $rootScope.tags = tags
        $rootScope.$broadcast('event:tags-fetched')

angular
  .module('ngAirPair')
  .factory('Tag', ['$rootScope', 'Restangular', ngTag])
