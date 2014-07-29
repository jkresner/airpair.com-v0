Config = ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
   .when '/settings/notifications',
     templateUrl: '/templates/settings/notifications'
     controller: 'NotificationSettingsController'
   .when '/coming',
     templateUrl: '/templates/coming'
     controller: 'ComingController'

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
require("./controllers/notificationSettingsController")
require("./controllers/comingController")
