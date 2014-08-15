NotificationSettingsController = ($rootScope, $scope, CurrentExpert) ->
  $scope.hourRange = _.map(new Array(20), (a, i) -> (i+1).toString())

  $scope.expert = CurrentExpert
  $scope.helper = new Helper($scope.expert)

  values = [10, 40, 70, 110, 160, 230]
  movePublicRateTag = (index) =>
    $(".slider-col .tag").css('margin-left', "#{values.indexOf(parseInt(index)) * 20}%")
  $(".hourly .slider").noUiSlider
    start: [ 3, 4 ]
    step: 1
    margin: 0
    connect: true
    direction: "ltr"
    orientation: "horizontal"
    behaviour: "tap-drag"
    range:
      min: 0
      max: 5
    serialization:
      format:
        decimals: 0
        encoder: (value) ->
          values[value]

  $('.hourly .slider').val([values.indexOf($scope.expert.minRate), values.indexOf($scope.expert.rate)])
  movePublicRateTag($scope.expert.rate)

  $('.hourly .slider').change (event, value) =>
    movePublicRateTag(value[1])
    $scope.expert.minRate = value[0]
    $scope.expert.rate = value[1]
    $scope.helper.update()


angular
  .module('ngAirPair')
  .controller('NotificationSettingsController', ['$rootScope', '$scope', 'CurrentExpert', NotificationSettingsController])
