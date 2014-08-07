SessionFactory = ($http, $window) ->
  session =
    data: $window.session

    authToken: ->
      @data.user.authToken

    isSignedIn: ->
      @data? && @data.user? && @data.user._id?

    id: ->
      if @isSignedIn()
        @data.user._id

    name: ->
      if @isSignedIn()
        @data.user.google.displayName

  session

angular
  .module('ngAirPair')
  .factory('Session', ['$http', '$window', SessionFactory])

