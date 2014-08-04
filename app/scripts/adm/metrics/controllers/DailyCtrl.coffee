
# DAILY

angular.module('AirpairAdmin').controller("DailyCtrl", ['$scope', '$moment', 'apData', ($scope, $moment, apData ) ->

  $scope.weeks = apData.ads.daily moment().subtract('w', 3)


  console.log "daily report", $scope.weeks

])