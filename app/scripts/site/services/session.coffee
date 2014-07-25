SessionFactory = ($http) ->
  session =
    data: {}

    isSignedIn: ->
      @data.user? && @data.user._id?

    id: ->
      if @isSignedIn()
        @data.user._id

    name: ->
      if @isSignedIn()
        @data.user.google.displayName

    updateSession: ->
      $http.get('/api/session')
        .success (data) =>
          @data = data
        .error (data) ->
          console.error('Error: ' + data)

  session.updateSession()
  session

angular
  .module('ngAirPair')
  .factory('Session', ['$http', SessionFactory])

