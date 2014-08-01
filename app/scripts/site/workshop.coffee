Config = ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
   .when '/workshops/me',
     templateUrl: '/templates/workshop/schedule'
     controller: 'WorkshopController'

   .when '/:tag/workshops/:id',
     templateUrl: '/templates/workshop/detail'
     controller: 'WorkshopController'

  $locationProvider.html5Mode(true)
  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setRestangularFields(id: "_id")

angular
  .module('ngAirPair', ['ngRoute', 'firebase', 'restangular'])
  .config(['$routeProvider', '$locationProvider', 'RestangularProvider', Config])
  .run(['$rootScope', ($rootScope) ->
    $rootScope._ = window._
    $rootScope.moment = window.moment
  ])

require("./services/session")
require("./services/workshop")
require("./controllers/sessionController")
require("./controllers/workshopController")
require("./controllers/chatController")
