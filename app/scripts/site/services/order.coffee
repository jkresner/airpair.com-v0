ngOrder = ($http, $rootScope, Restangular) ->
  class Order

    data = {}

    constructor:  ->
      @fetchOrder()

    fetchOrder: ->
      Restangular.one('experts', 'me').get().then (expert) =>
        data.expert = expert
        initializeTags()
        fetchExpertRequests(expert._id)
        fetchExpertOrders(expert._id)

  new Order

angular
  .module('ngAirPair')
  .factory('Order', ['$http', '$rootScope', 'Restangular', ngOrder])
