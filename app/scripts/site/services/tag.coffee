ngTag = ($rootScope, Restangular) ->
  restangular = Restangular.service('tags/lean')
  all: =>
    restangular.getList()

angular
  .module('ngAirPair')
  .factory('Tag', ['$rootScope', 'Restangular', ngTag])
