WorkshopController = ($scope, Session, Workshop) ->
  $scope.session = Session
  $scope.workshop = Session.data.workshop

  $scope.showLocalTimes = ->
    showLocalTimes()
    true

  $scope.registered = ->
    Session.data.registration? && Session.data.registration.paid

  $scope.showRsvp = ->
    Session.data.registration? && Session.data.registration.paid && !$scope.attending()

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
