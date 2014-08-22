ngExpert = ($rootScope, Restangular) ->
  restangular = Restangular.service('experts')

  get: (id) =>
    restangular.one(id).get()

angular
  .module('ngAirPair')
  .factory('Expert', ['$rootScope', 'Restangular', ngExpert])
