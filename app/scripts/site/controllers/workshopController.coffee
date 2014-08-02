WorkshopController = ($scope, Session, Workshop) ->
  $scope.session = Session
  $scope.workshop = Session.data.workshop

  $scope.registered = ->
    Session.data.registration?

  $scope.showRsvp = ->
    Session.data.registration? && !$scope.attending()

  $scope.attending = ->
    attending = _.find Workshop.attendingWorkshops, (workshop) ->
      workshop.slug == Session.data.workshop.slug
    attending?

  $scope.attendingAny = ->
    _.any(Workshop.attendingWorkshops)

  $scope.allAttending = ->
    Workshop.attendingWorkshops

  $scope.attend = ->
    Workshop.attendSession(Session.data.workshop.slug)

angular
  .module('ngAirPair')
  .controller('WorkshopController', ['$scope', 'Session', 'Order', WorkshopController])
