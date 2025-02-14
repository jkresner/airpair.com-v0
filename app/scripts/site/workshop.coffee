Config = ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
   .when '/workshops/me',
     templateUrl: '/templates/workshop/schedule'
     controller: 'WorkshopController'

   .when '/:tag/workshops/:id',
     templateUrl: '/templates/workshop/detail'
     controller: 'WorkshopController'

   .when '/airconf2014/keynote/:id',
     templateUrl: '/templates/workshop/panel'
     controller: 'WorkshopController'

  $locationProvider.html5Mode(true)
  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setRestangularFields(id: "_id")

angular
  .module('ngAirPair', ['ngRoute', 'firebase', 'restangular', 'ngSanitize','ngAnimate','cgBusy','angularMoment','timer'])
  .config(['$routeProvider', '$locationProvider', 'RestangularProvider', Config])
  .run(['$rootScope', ($rootScope) ->
    $rootScope._ = window._
  ])

Array.prototype.toSentence = ->
  @slice(0, @length - 1).join(', ') + " and " + @slice(-1)

require("./services/session")
require("./services/workshop")
require("./controllers/sessionController")
require("./controllers/workshopController")
require("./directives/chat_directive")

# todo: move to config for chat_directive
require("./filters/reverse")
require("./filters/uniq")
