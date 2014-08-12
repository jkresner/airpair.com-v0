NotificationSettingsController = ($scope, Expert) ->
  _.forIn Expert, (value, key) -> $scope[key] = value
  $scope.hourRange = _.map(new Array(20), (a, i) -> (i+1).toString())
  values = [10, 40, 70, 110, 160, 230]

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

  movePublicRateTag = (index) =>
    $(".slider-col .tag").css('margin-left', "#{values.indexOf(parseInt(index)) * 20}%")

  $('.hourly .slider').change (event, value) =>
    movePublicRateTag(value[1])
    Expert.setRate(value[0], value[1])
    Expert.update()

  $('.send-toggle').click (event, value) =>
    $(".send-toggle .toggle.on").toggleClass("active", !$("#status").prop("checked"))
    $(".send-toggle .toggle.off").toggleClass("active", !!$("#status").prop("checked"))
    $("#status").click()
    true

  $scope.$watch Expert.status(), (newValue, oldValue) =>
    $(".send-toggle .toggle.on").toggleClass("active", !!Expert.status())
    $(".send-toggle .toggle.off").toggleClass("active", !Expert.status())

  $scope.$watchGroup [Expert.minRate(), Expert.rate()], (newValue, oldValue) =>
    $('.hourly .slider').val([values.indexOf(Expert.minRate()), values.indexOf(Expert.rate())])
    movePublicRateTag(Expert.rate())

  $('form.tags').on 'click', '.type', ->
    allTags = $(this).parents(".level").find('input[type="checkbox"]')
    uncheckedTags = allTags.not(":checked")
    if uncheckedTags.size() > 0
      uncheckedTags.click()
    else
      allTags.click()

angular
  .module('ngAirPair')
  .controller('NotificationSettingsController', ['$scope', 'Expert', NotificationSettingsController])
