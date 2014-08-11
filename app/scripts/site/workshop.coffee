Config = ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
   .when '/workshops/me',
     templateUrl: '/templates/workshop/schedule'
     controller: 'WorkshopController'

   .when '/:tag/workshops/:id',
     templateUrl: '/templates/workshop/detail'
     controller: 'WorkshopController'

   .when '/airconf2014/keynote/:id',
     templateUrl: '/templates/workshop/keynote'
     controller: 'WorkshopController'

  $locationProvider.html5Mode(true)
  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setRestangularFields(id: "_id")

angular
  .module('ngAirPair', ['ngRoute', 'firebase', 'restangular', 'ngSanitize','ngAnimate','cgBusy','angularMoment'])
  .config(['$routeProvider', '$locationProvider', 'RestangularProvider', Config])
  .run(['$rootScope', ($rootScope) ->
    $rootScope._ = window._
  ])

require("./services/session")
require("./services/workshop")
require("./controllers/sessionController")
require("./controllers/workshopController")
require("./directives/chat_directive")

# todo: move to config for chat_directive
require("./filters/reverse")
require("./filters/uniq")
