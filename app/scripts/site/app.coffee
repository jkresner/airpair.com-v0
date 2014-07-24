window.app = angular.module('ngAirPair', ['ngRoute', 'restangular'])
app.config ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
   .when '/experts/me',
     templateUrl: '/templates/experts/me'
     controller: 'ExpertSettingsController as expert'

  $locationProvider.html5Mode(true)
  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setRestangularFields(id: "_id")

require("./directives/ngDelay")(app)
require("./services/session")(app)
require("./services/expert")(app)
require("./controllers/headerController")(app)
require("./controllers/expertSettingsController")(app)

module.exports = -> app
