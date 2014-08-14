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
    @registered() and not @attending()

  $scope.started = ->
    Session.data.workshop.youtube? && Session.data.workshop.youtube.length > 0

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
    # specifically for marketing metrics
    addjs.trackCustomEvent 'WorkshopRSVP', {slug: Session.data.workshop.slug}

  $scope.youtubeUrl = ->
    url = "//www.youtube.com/embed/#{Session.data.workshop.youtube}"
    $sce.trustAsResourceUrl(url)

  ###
  Workshop Metrics
  ###
  props =
    slug: Session.data.workshop.slug
    started: $scope.started()

  if Session.isSignedIn()
    if $scope.registered()
      addjs.trackCustomEvent 'WorkshopViewByRegisteredAttendee', props
    else
      addjs.trackCustomEvent 'WorkshopViewByUnregisteredUser', props

  else
    addjs.trackCustomEvent 'WorkshopViewByPublic', props

###
Angular Declarations
###
angular
  .module('ngAirPair')
  .controller('WorkshopController', ['$scope', '$sce', 'Restangular', 'Session', 'Order', WorkshopController])
