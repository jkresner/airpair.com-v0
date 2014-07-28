ExpertSettingsController = ($scope, $timeout, Expert) ->
  _.extend(@, Expert)
  @hourRange = _.map(new Array(20), (a, i) -> (i+1).toString())
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

  $('.hourly .slider').change (event, value) =>
    @setRate(value[0], value[1])
    @update()

  $('.send-toggle').click (event, value) =>
    $(".send-toggle .toggle.on").toggleClass("active", !$("#status").prop("checked"))
    $(".send-toggle .toggle.off").toggleClass("active", !!$("#status").prop("checked"))
    $("#status").click()
    true

  $scope.$watch @status, (newValue, oldValue) ->
    $(".send-toggle .toggle.on").toggleClass("active", !!@status())
    $(".send-toggle .toggle.off").toggleClass("active", !@status())

  $scope.$watchGroup [@minRate, @rate], (newValue, oldValue) ->
    $('.hourly .slider').val([values.indexOf(@minRate()), values.indexOf(@rate())])

  $scope.$watch @tags, (newValue, oldValue) ->
    $('form.tags .type').each ->
      allTags = $(this).parents(".level").find('input[type="checkbox"]')
      uncheckedTags = allTags.not(":checked")
      if uncheckedTags.size() > 0
        $(this).children('.all-levels').removeClass('active')
      else
        $(this).children('.all-levels').addClass('active')

  $('form.tags').on 'click', '.type', ->
    allTags = $(this).parents(".level").find('input[type="checkbox"]')
    uncheckedTags = allTags.not(":checked")
    if uncheckedTags.size() > 0
      uncheckedTags.click()
    else
      allTags.click()
  @

angular
  .module('ngAirPair')
  .controller('ExpertSettingsController', ['$scope', '$timeout', 'Expert', ExpertSettingsController])
