ngWorkshop = ($http, Session, Restangular) ->
  class Workshop

    requestId = Session.data.requestId


    constructor:  ->
      @fetchAttendingWorkshops()

    attendingWorkshops: []

    fetchAttendingWorkshops: ->
      Restangular.all('workshops/user').getList().then (workshops)=>
        for workshop in workshops
          @attendingWorkshops.push(workshop)

    attendSession: (slug)->
      $http.post("/api/workshops/#{slug}/attendees", {requestId})
        .success (data, status)=>
          @fetchAttendingWorkshops()


  new Workshop

angular
  .module('ngAirPair')
  .factory('Order', ['$http', 'Session', 'Restangular', ngWorkshop])
