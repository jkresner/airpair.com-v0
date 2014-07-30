Config = ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
   .when '/airconf/:id',
     templateUrl: '/templates/workshop/detail'
     controller: 'WorkshopDetailController'

  $locationProvider.html5Mode(true)
  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setRestangularFields(id: "_id")

angular
  .module('ngAirPair', ['ngRoute', 'restangular'])
  .config(['$routeProvider', '$locationProvider', 'RestangularProvider', Config])
  .run(['$rootScope', ($rootScope) ->
    $rootScope._ = window._
  ])

require("./services/session")
require("./services/order")
require("./controllers/sessionController")
require("./controllers/workshopDetailController")
