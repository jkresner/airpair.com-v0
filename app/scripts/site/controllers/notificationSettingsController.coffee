NotificationSettingsController = ($location, $rootScope, $scope, CurrentExpert) ->
  $scope.hourRange = _.map(new Array(20), (a, i) -> (i+1).toString())

  $scope.expert = CurrentExpert

  # redirect to be an expert if the user is not an expert
  $location.path("/settings/expert") unless $scope.expert.exists?

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

  $scope.initSlider = ->
    $('.hourly .slider').val([values.indexOf(parseInt($scope.expert.minRate)), values.indexOf(parseInt($scope.expert.rate))])
    movePublicRateTag($scope.expert.rate)
    $scope.expert.name?

  $('.hourly .slider').change (event, value) =>
    movePublicRateTag(value[1])
    $scope.expert.minRate = parseInt(value[0])
    $scope.expert.rate = parseInt(value[1])
    $scope.expert.update()

angular
  .module('ngAirPair')
  .controller('NotificationSettingsController', ['$location', '$rootScope', '$scope', 'CurrentExpert', NotificationSettingsController])
