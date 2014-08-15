ngWorkshop = ($http, Session, Restangular) ->
  class Workshop
    attendees: Session.data.attendees
    attendingWorkshops: Session.data.attendingWorkshops

    attendSession: (slug) ->
      $http.post("/api/workshops/#{slug}/attendees")
        .success (data, status) =>
          @attendees.push
            id: Session.data.user.google._json.id
            name: Session.data.user.google._json.name
            picture: Session.data.user.google._json.picture

          @attendingWorkshops.push(Session.data.workshop)

  new Workshop

angular
  .module('ngAirPair')
  .factory('Order', ['$http', 'Session', 'Restangular', ngWorkshop])
