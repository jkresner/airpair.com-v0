window.app = angular.module('ngAirPair', ['ngRoute'])
app.config ($routeProvider, $locationProvider) ->
  $routeProvider
   .when '/experts/me',
     templateUrl: '/templates/experts/me'
     controller: 'ExpertSettingsController'

  $locationProvider.html5Mode(true)

require("./services/global")(app)
require("./controllers/expertSettingsController")(app)

module.exports = -> app
