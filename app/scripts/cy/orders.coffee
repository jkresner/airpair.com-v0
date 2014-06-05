calcExpertCredit = require 'lib/mix/calcExpertCredit'

{calcTotal, calcRedeemed, calcCompleted} = calcExpertCredit




module.exports = (pageData) ->


  
  # Create new app
  angular.module("AirpairAdmin", ["ngRoute", "ui.bootstrap"]).




  # Configs
  config(($routeProvider, $locationProvider) ->

    $locationProvider.html5Mode true

    $routeProvider.
      when('/adm/ang/orders',           {controller: 'OrdersCtrl',  templateUrl: "/adm/templates/orders.html"}).
      when('/adm/ang/orders/edit/:id',  {controller: 'OrdersCtrl',  templateUrl: "/adm/templates/orders_edit.html"}).
      otherwise({redirectTo: '/'})
  ).




  # CONTROLLER –  Orders
  
  controller "OrdersCtrl", ["$scope", "$location", ($scope, $location) ->
    
    allOrders = pageData.orders

    # Iterate through orders
    for order in allOrders
      order.lineItems = order.lineItems.map (li) ->
        expertCredit = calcExpertCredit [order], li.suggestion.expert._id
        li.incomplete = expertCredit.total is 0 or expertCredit.completed < expertCredit.total
        _.extend li, expertCredit


    # Default date range from 6 weeks ago to today
    $scope.dateStart = new Date(new Date().getTime() - 1000*60*60*24*7*6)
    $scope.dateEnd = new Date()



    $scope.isWithinDate = (order) ->
      orderDate = new Date(order.utc)
      return orderDate > $scope.dateStart && orderDate < $scope.dateEnd
    

    $scope.updateOrderList = () ->
      $scope.visibleOrders = []      
      for order in allOrders
        if $scope.isWithinDate(order)
          $scope.visibleOrders.push order

      $scope.calcSummary()
      # console.log "visibleOrders", $scope.visibleOrders

      
    $scope.calcSummary = () ->
      $scope.summary = 
        totalRevenue: 0
        orderCount: 0
        customerCount: 0
        requestCount: 0 
        totalRedeemed: 0
        totalCompleted: 0
        totalHours: 0 
        expertCount: 0
        totalProfit: 0
        experts: []

      for order in $scope.visibleOrders
        if $scope.isWithinDate(order)
          $scope.summary.totalRevenue += order.total
          $scope.summary.totalProfit += order.profit
          for item in order.lineItems
            $scope.summary.totalRedeemed += calcRedeemed [item]
            $scope.summary.totalCompleted += calcCompleted [item]
            $scope.summary.totalHours += calcTotal [item]
            $scope.summary.experts.push item.suggestion.expert._id

      $scope.summary.orderCount = $scope.visibleOrders.length      
      $scope.summary.customerCount = _.uniq(_.pluck $scope.visibleOrders, 'userId').length
      $scope.summary.requestCount = _.uniq(_.pluck $scope.visibleOrders, 'requestId').length
      $scope.summary.expertCount = _.uniq($scope.summary.experts).length


    # Watch date selector
    $scope.$watch "dateStart", () -> $scope.updateOrderList()
    $scope.$watch "dateEnd", () -> $scope.updateOrderList()


    



    



  ]

      

      