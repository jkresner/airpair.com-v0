ngOrder = ($http, Session, Restangular) ->
  class Order

    requestId = Session.data.requestId


    constructor:  ->
      @fetchOrders()

    orders: []

    fetchOrders: ->
      Restangular.one('orders/request', requestId).get().then (orders) =>
        @orders.push()

  new Order

angular
  .module('ngAirPair')
  .factory('Order', ['$http', 'Session', 'Restangular', ngOrder])
