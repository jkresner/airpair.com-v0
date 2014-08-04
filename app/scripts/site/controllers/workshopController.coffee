WorkshopController = ($scope, $sce, Session, Workshop) ->
  $scope.session = Session
  $scope.workshop = Session.data.workshop

  $scope.showLocalTimes = ->
    showLocalTimes()
    true

  $scope.registered = ->
    Session.data.registration? && Session.data.registration.paid

  $scope.showRsvp = ->
    Session.data.registration? && Session.data.registration.paid && !$scope.attending() && !$scope.started()

  $scope.started = ->
    attending = _.find Workshop.attendingWorkshops, (workshop) ->
      workshop.slug == Session.data.workshop.slug
    attending && Session.data.workshop.youtube? && Session.data.workshop.youtube.length > 0

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
  .controller('WorkshopController', ['$scope', '$sce', 'Session', 'Order', WorkshopController])
