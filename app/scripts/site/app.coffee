module.exports = ->
  window.app = angular.module('ngAirPair', ['ngRoute'])
  app.config ($routeProvider, $locationProvider) ->
    $routeProvider
     .when '/angularController',
       templateUrl: '/templates/test'
       controller: 'ExpertsController'

    $locationProvider.html5Mode(true)

  require("./services/global")(app)
  require("./controllers/expertsController")(app)
  app
