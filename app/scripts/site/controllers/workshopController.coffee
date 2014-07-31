WorkshopController = ($scope, Session, Workshop) ->
  $scope.workshop = Session.data.workshop

  $scope.attend = ->
    Workshop.attendSession(Session.data.workshop.slug)

  $scope.attending = ->
    attending = _.find Workshop.attendingWorkshops, (workshop) ->
      workshop.slug == Session.data.workshop.slug
    attending?

angular
  .module('ngAirPair')
  .controller('WorkshopController', ['$scope', 'Session', 'Order', WorkshopController])
