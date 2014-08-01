WorkshopController = ($scope, Session, Workshop) ->
  $scope.session = Session
  $scope.workshop = Session.data.workshop

  $scope.attend = ->
    Workshop.attendSession(Session.data.workshop.slug)

  $scope.attending = ->
    attending = _.find Workshop.attendingWorkshops, (workshop) ->
      workshop.slug == Session.data.workshop.slug
    attending?

  $scope.attendingAny = ->
    _.any(Workshop.attendingWorkshops)

  $scope.allAttending = ->
    Workshop.attendingWorkshops

angular
  .module('ngAirPair')
  .controller('WorkshopController', ['$scope', 'Session', 'Order', WorkshopController])
