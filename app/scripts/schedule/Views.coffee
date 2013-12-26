exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'
expertAvailability = require '../shared/mix/expertAvailability'

# schedule form
class exports.ScheduleFormView extends BB.ModelSaveView
  # todo delete
  logging: on
  el: '#scheduleForm'
  tmpl: require './templates/ScheduleForm'
  viewData: ['duration', 'date', 'expertId']
  events:
    'click input:radio': (e) ->
      @model.set 'expertId', @$(e.target).val()
      @model.set 'type', @elm('type').val()
    'change [name=type]': -> @model.set 'type', @elm('type').val()
    'click #create': 'save'
  initialize: ->
    @listenTo @request, 'change', @render
    @listenTo @collection, 'sync', @render
    @listenTo @model, 'change', @render

  render: ->
    return if @collection.isEmpty() || !@request.get('userId')?
    orders = @collection.toJSON()
    selectedExpert = null
    suggested = @request.get('suggested') || []
    suggested = suggested
      .filter (suggestion) =>
        suggestion.expertStatus == 'available'
      .map (suggestion) =>
        suggestion.expert.balance = expertAvailability orders, suggestion.expert._id
        suggestion.expert.balance.byTypeArray = _.values(suggestion.expert.balance.byType)

        # selects the first expert by default when there's only one
        if suggested.length == 1
          @model.set 'expertId', suggestion.expert._id
          @model.set 'type', @request.get 'pricing'

        if @mget('expertId') == suggestion.expert._id
          suggestion.expert.selected = suggestion.expert
          selectedExpert = suggestion.expert
        suggestion

    if selectedExpert
      balance = (selectedExpert.balance.byType[@mget('type')] || {}).balance || 0
      selectedExpert.selectOptions = _.range(1, balance + 1).map (num) -> { num }

    d = @model.extendJSON { available: suggested, selectedExpert, requestId: @model.requestId }
    @$el.html @tmpl d
    @

# class exports.ScheduledView extends BB.BadassView
#   # todo
#   logging: on
#   el: '#scheduled'
#   tmpl: require './templates/Scheduled'
#   initialize: ->
#     @listenTo @model, 'change', @render
#     @render()
#   render: ->

module.exports = exports
