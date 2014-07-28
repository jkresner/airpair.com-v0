Config = ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
   .when '/experts/me',
     templateUrl: '/templates/experts/me'
     controller: 'ExpertSettingsController as expert'

  $locationProvider.html5Mode(true)
  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setRestangularFields(id: "_id")

angular
  .module('ngAirPair', ['ngRoute', 'restangular'])
  .config(['$routeProvider', '$locationProvider', 'RestangularProvider', Config])
  .run(['$rootScope', ($rootScope) ->
    $rootScope._ = window._
  ])

require("./directives/ngDelay")
require("./services/session")
require("./services/expert")
require("./controllers/headerController")
require("./controllers/expertSettingsController")
