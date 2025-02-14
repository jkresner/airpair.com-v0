

module.exports = (pageData) ->

  window.pageData = pageData


  # Create new app
  angular.module("AirpairAdmin", ["ngRoute", "ui.bootstrap"]).

  # Configs
  config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->

    $locationProvider.html5Mode true

    $routeProvider.
      when('/adm/ang/orders/growth',             { controller: 'GrowthCtrl',           templateUrl: "/adm/templates/orders_growth.html",   resolve: {title: () -> document.title = "Monthly" }}).
      when('/adm/ang/orders/channels_orders',    { controller: 'ChannelsCtrl',         templateUrl: "/adm/templates/orders_channels.html", resolve: {title: () -> document.title = "Orders by Channels" }}).
      when('/adm/ang/orders/channels_requests',  { controller: 'ChannelsRequestsCtrl', templateUrl: "/adm/templates/orders_channels_requests.html", resolve: {title: () -> document.title = "Requests by Channels" }}).
      when('/adm/ang/orders/weekly',             { controller: 'WeeklyCtrl',           templateUrl: "/adm/templates/orders_weekly.html",   resolve: {title: () -> document.title = "Weekly" }}).
      when('/adm/ang/orders/daily',              { controller: 'DailyCtrl',            templateUrl: "/adm/templates/orders_daily",         resolve: {title: () -> document.title = "Daily" }}).
      when('/adm/ang/orders/edit/:id',           { controller: 'OrdersCtrl',           templateUrl: "/adm/templates/orders_edit.html",     resolve: {title: () -> document.title = "Edit" }}).
      when('/adm/ang/orders',                    { controller: 'OrdersCtrl',           templateUrl: "/adm/templates/orders.html",          resolve: {title: () -> document.title = "Orders" }}).
      otherwise({redirectTo: '/'})
  ])


  # Filters
  require "./metrics/filters/numFloor"

  # Services
  require "./metrics/services/$moment"
  require "./metrics/services/$mixpanel"
  require "./metrics/services/$helpers"
  require "./metrics/services/apData"

  # Directives
  require "./metrics/directives/apTableGrowth"
  require "./metrics/directives/apTableChannels"

  #Controllers
  require "./metrics/controllers/NavCtrl"
  require "./metrics/controllers/OrdersCtrl"
  require "./metrics/controllers/WeeklyCtrl"
  require "./metrics/controllers/GrowthCtrl"
  require "./metrics/controllers/ChannelsCtrl"
  require "./metrics/controllers/ChannelsRequestsCtrl"
  require "./metrics/controllers/DailyCtrl"






