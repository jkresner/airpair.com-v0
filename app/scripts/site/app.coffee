Config = ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
   .when '/be-an-expert',
     templateUrl: '/templates/settings/expert_connect'
     controller: 'ExpertSettingsController'
   .when '/settings/notifications',
     templateUrl: '/templates/settings/notifications'
     controller: 'NotificationSettingsController'
   .when '/coming',
     templateUrl: '/templates/shared/coming'
     controller: 'ComingController'

  $locationProvider.html5Mode(true)
  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setRestangularFields(id: "_id")

angular
  .module('ngAirPair', ['ngRoute', 'restangular', 'ui.select2'])
  .config(['$routeProvider', '$locationProvider', 'RestangularProvider', Config])
  .run(['$rootScope', ($rootScope) ->
    $rootScope._ = window._
  ])

require("./directives/select2")
require("./directives/ngDelay")

require("./services/session")
require("./services/expert")
require("./services/currentExpert")
require("./services/tag")

require("./controllers/headerController")
require("./controllers/expertSettingsController")
require("./controllers/notificationSettingsController")
require("./controllers/comingController")
