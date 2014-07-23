window.app = angular.module('ngAirPairAdmin', ['ngRoute','tagger','restangular'])

app.config ($routeProvider, $locationProvider) ->
  $routeProvider
   .when '/admin/automatch',
     templateUrl: '/templates/admin/automatch'
     controller: 'AutoMatchController'

  $locationProvider.html5Mode(true)

app.config (RestangularProvider) ->
  RestangularProvider.setBaseUrl('/api')


require("../site/services/session")(app)
require("../site/controllers/headerController")(app)
require("./controllers/automatchController")(app)

app.run ($rootScope) ->
  $rootScope._ = window._

module.exports = -> app
