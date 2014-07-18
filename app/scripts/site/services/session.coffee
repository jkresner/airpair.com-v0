module.exports = (app) ->
  app.factory 'Session', ($http) ->
    Session =
      data: {}

      isSignedIn: ->
        @data.user? && @data.user._id?

      name: ->
        if @isSignedIn()
          @data.user.google.displayName

      updateSession: ->
        $http.get('/api/session')
          .success (data) =>
            @data = data
          .error (data) ->
            console.log('Error: ' + data)
        @

    Session.updateSession()
