ngWorkshop = ($http, Session, Restangular) ->
  class Workshop
    requestId = Session.data.requestId

    attendingWorkshops: []
    attendees: []

    setArray: (arrayName, data) ->
      @[arrayName].length = 0 # wat?
      for datum in data
        @[arrayName].push(datum)

    fetchAttendingWorkshops: ->
      if Session.isSignedIn()
        Restangular.all('workshops/user').getList().then (workshops) =>
          @setArray("attendingWorkshops", workshops)

    getAudienceFor: (slug) ->
        Restangular.all("workshops/#{slug}/attendees").getList()
        .then (attendees) =>
          @setArray("attendees", attendees)

    attendSession: (slug) ->
      $http.post("/api/workshops/#{slug}/attendees", {requestId})
        .success (data, status)=>
          @fetchAttendingWorkshops()
          @getAudienceFor(slug)

  new Workshop

angular
  .module('ngAirPair')
  .factory('Order', ['$http', 'Session', 'Restangular', ngWorkshop])
