module.exports = (app) ->
  app.factory 'global', ->
    {
      currentUser: -> currentUser
      isSignedIn: -> !!currentUser
      currentId: -> currentId
    }
