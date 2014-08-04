

# Nav Controller
angular.module('AirpairAdmin').controller("NavCtrl", [ '$scope', '$location', ($scope, $location) ->
  # A function to add class to nav items
  $scope.navClass = (page) ->
    currentRoute = $location.path().substring(16) or "browse"
    if page is currentRoute then "active" else ""
])
