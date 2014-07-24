window.app = angular.module('ngAirPair', ['ngRoute'])
app.config ($routeProvider, $locationProvider) ->
  $routeProvider
   .when '/experts/me',
     templateUrl: '/templates/experts/me'
     controller: 'ExpertSettingsController as expert'

  $locationProvider.html5Mode(true)

require("./services/session")(app)
require("./services/expert")(app)
require("./controllers/headerController")(app)
require("./controllers/expertSettingsController")(app)

module.exports = -> app
