WorkshopDetailController = ($scope, Session, Order) ->
  $scope.workshop = Session.data.workshop
  $scope.ordered = ->
    false

angular
  .module('ngAirPair')
  .controller('WorkshopDetailController', ['$scope', 'Session', 'Order', WorkshopDetailController])
