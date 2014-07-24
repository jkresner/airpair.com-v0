ExpertSettingsController = (Expert) ->
  _.extend(@, Expert)
  @hourRange = _.map(new Array(20), (a, i) -> (i+1).toString())
  window.Expert = @
  _hours = '3'
  @name = (value) ->
    console.log "name", value
    if value?
      console.log "value"
      _hours = value
    _hours

  $(".level .slider").noUiSlider
    start: [ 1, 2 ]
    step: 1
    margin: 0
    connect: true
    direction: "ltr"
    orientation: "horizontal"
    behaviour: "tap-drag"
    range:
      min: 1
      max: 3
    serialization:
      lower: [$.Link(target: $("#value-input"))]
      upper: [$.Link( target: $("#value-input2") )]
      format:
        decimals: 0
  $(".hourly .slider").noUiSlider
    start: [ 70, 100 ]
    step: 1
    margin: 0
    connect: true
    direction: "ltr"
    orientation: "horizontal"
    behaviour: "tap-drag"
    range:
      min: 10
      max: 230
    serialization:
      lower: [$.Link(target: $("#hourly1"))]
      upper: [$.Link( target: $("#hourly2") )]
      format:
        decimals: 0
        prefix: "$"
  @

module.exports = (app) ->
  app.controller 'ExpertSettingsController', ExpertSettingsController
