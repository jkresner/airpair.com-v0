SessionFactory = ($http, $window) ->
  session =
    data: $window.session

    isSignedIn: ->
      @data? && @data.user? && @data.user._id?

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
          console.log('Error: ' + data)
  session

angular
  .module('ngAirPair')
  .factory('Session', ['$http', '$window', SessionFactory])

