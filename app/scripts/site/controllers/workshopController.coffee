WorkshopController = ($scope, $sce, Restangular, Session, Workshop) ->
  $scope.session = Session
  $scope.workshop = Session.data.workshop

  if Session.isSignedIn()
    attendingWorkshops = Session.data.attendingWorkshops
    if attendingWorkshops?
      Workshop.setArray('attendingWorkshops', attendingWorkshops)
    else
      Workshop.fetchAttendingWorkshops()

    attendees = Session.data.attendees
    if attendees?
      Workshop.setArray('attendees', attendees)
    else
      Workshop.getAudienceFor(Session.data.workshop.slug)

  $scope.audience = ->
    Workshop.attendees

  $scope.showLocalTimes = ->
    showLocalTimes()
    true

  $scope.registered = ->
    Session.data.registration? && Session.data.registration.paid

  $scope.showRsvp = ->
    Session.data.registration? && Session.data.registration.paid && !$scope.attending() && !$scope.started()

  $scope.started = ->
    @attending() && Session.data.workshop.youtube? && Session.data.workshop.youtube.length > 0

  $scope.keynoteStarted = ->
    Session.data.workshop.youtube?

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

  $scope.youtubeUrl = ->
    url = "//www.youtube.com/embed/#{Session.data.workshop.youtube}"
    $sce.trustAsResourceUrl(url)

angular
  .module('ngAirPair')
  .controller('WorkshopController', ['$scope', '$sce', 'Restangular', 'Session', 'Order', WorkshopController])
