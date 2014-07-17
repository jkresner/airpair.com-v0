module.exports = (app) ->
  app.factory 'global', ->
    {
      currentUser: currentUser
      name: currentUser.google._json.name
      isSignedIn: currentUser._id?
    }
