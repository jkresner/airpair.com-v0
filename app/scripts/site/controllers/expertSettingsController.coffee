ExpertSettingsController = (Expert, $scope) ->
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
      lower: [$.Link(target: $("#minRate"))]
      upper: [$.Link( target: $("#rate") )]
      format:
        decimals: 0
        encoder: (value) ->
          values[value]

  $('.hourly .slider').change (event, value) =>
    @minRate(value[0])
    @rate(value[1])
    @update()

  $scope.$on '$viewContentLoaded', =>
    $('.hourly .slider').val([values.indexOf(@minRate()), values.indexOf(@rate())])

  @



module.exports = (app) ->
  app.controller 'ExpertSettingsController', ExpertSettingsController
