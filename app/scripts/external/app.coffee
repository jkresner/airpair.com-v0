Config = ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
   .when '/login',
     templateUrl: '/templates/external/login'
     controller: 'LoginController'
   .when '/be-an-expert',
     templateUrl: '/templates/external/beexpert'
     controller: 'ExpertController'

  $locationProvider.html5Mode(true)
  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setRestangularFields(id: "_id")

angular
  .module('ngAirPair', ['ngRoute', 'restangular', 'segmentio'])
  .config(['$routeProvider', '$locationProvider', 'RestangularProvider', Config])
  .run(['$rootScope', ($rootScope) ->
    $rootScope._ = window._
  ])

require("../site/services/segmentio")
require("../site/services/session")

require("./controllers/loginController")
require("./controllers/expertController")
