module.exports = (app) ->
  app.controller 'ExpertSettingsController',
    ($scope, $http, $window, Session, Expert) ->
      _.extend($scope, Expert)
      window.Expert = Expert
