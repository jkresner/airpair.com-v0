Config = ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider
    .when '/adm/matching',
      templateUrl: '/templates/admin/automatch'
      controller: 'AutoMatchController'
      reloadOnSearch: false

  $locationProvider.html5Mode(true)

  RestangularProvider.setBaseUrl('/api')

angular
  .module('ngAirPair', ['ngRoute','tagger','restangular'])
  .config(['$routeProvider', '$locationProvider', 'RestangularProvider', Config])
  .run(['$rootScope', ($rootScope) ->
    $rootScope._ = window._
  ])

require("../site/services/session")
require("../site/controllers/headerController")
require("./controllers/automatchController")
