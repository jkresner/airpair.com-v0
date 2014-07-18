module.exports = ->
  window.app = angular.module('ngAirPair', ['ngRoute', 'firebase'])
  app.config ($routeProvider, $locationProvider) ->
    $routeProvider
     .when '/experts/me',
       templateUrl: '/templates/experts/me'
       controller: 'ExpertSettingsController'

    $locationProvider.html5Mode(true)

  require("./services/global")(app)
  require("./controllers/headerController")(app)
  require("./controllers/expertSettingsController")(app)
