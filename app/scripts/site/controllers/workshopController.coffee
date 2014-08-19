WorkshopController = ($scope, $sce, Restangular, Session, Workshop) ->
  $scope.session = Session
  $scope.workshop = Session.data.workshop

  $scope.audience = ->
    Workshop.attendees

  $scope.showLocalTimes = ->
    showLocalTimes()
    true

  $scope.startsAt = () ->
    moment(@workshop.time).unix() - moment().unix()

  $scope.registered = ->
    Session.isSignedIn() and Session.data.registration? and Session.data.registration.paid

  $scope.showCountdown = ->
    new Date(@workshop.time) > new Date

  $scope.showRsvp = ->
    @registered() and not @attending()

  $scope.started = ->
    Session.data.workshop.youtube? && Session.data.workshop.youtube.length > 0

  $scope.subscribeToMailingList = ->
    xhr = $.post("/api/landing/mailchimp/subscribe", {listId: "39f4769300", email: @emailAddress})
    xhr.done (data) ->
      $('.cta-section').html("<p>Thank you. Please check your email and <strong>click the confirmation link</strong> to complete your subscription.</p>")
      addjs.trackCustomEvent('SubcribedToNewsletterFromTalkPage')
      if window.localStorage
        window.localStorage['subscribed'] = true

    xhr.fail (resp, data) ->
      console.log('failed to subscribe', arguments)

  $scope.live = ->
    start = new Date(Session.data.workshop.time)
    moment().range(start, moment(start).add(1, 'hour')).contains(new Date)

  $scope.attending = ->
    _.find(Workshop.attendees, (u) -> Session.data.user.google._json.id == u.id)?

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
    live: $scope.live()

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
