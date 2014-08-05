ngWorkshop = ($http, Session, Restangular) ->
  class Workshop
    requestId = Session.data.requestId

    constructor:  ->
      @fetchAttendingWorkshops()

    attendingWorkshops: []
    attendees: []

    fetchAttendingWorkshops: ->
      if Session.isSignedIn()
        Restangular.all('workshops/user').getList().then (workshops) =>
          @attendingWorkshops.length = 0 # wat?
          for workshop in workshops
            @attendingWorkshops.push(workshop)

    getAudienceFor: (slug) ->
        Restangular.all("workshops/#{slug}/attendees").getList()
        .then (attendees) =>
          @attendees.length = 0 # wat?
          for attendee in attendees
            @attendees.push(attendee)

    attendSession: (slug) ->
      $http.post("/api/workshops/#{slug}/attendees", {requestId})
        .success (data, status)=>
          @fetchAttendingWorkshops()
          @getAudienceFor(slug)


  new Workshop

angular
  .module('ngAirPair')
  .factory('Order', ['$http', 'Session', 'Restangular', ngWorkshop])
