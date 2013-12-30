exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'
expertAvailability = require '../shared/mix/expertAvailability'

# schedule form
class exports.ScheduleFormView extends BB.ModelSaveView
  el: '#scheduleForm'
  tmpl: require './templates/ScheduleForm'
  viewData: ['duration', 'date', 'time', 'expertId', 'type']
  events:
    'click input:radio': (e) ->
      @model.set 'expertId', @$(e.target).val()
      @model.set 'type', @elm('type').val()
    'change [name=type]': -> @model.set 'type', @elm('type').val()
    'blur [name=date]': -> @model.set 'date', @elm('date').val()
    'blur [name=time]': -> @model.set 'time', @elm('time').val()
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
        expert = suggestion.expert
        expert.availability = expertAvailability orders, expert._id
        expert.availability.byTypeArray = _.values(expert.availability.byType)

        # selects the first expert by default when there's only one
        if suggested.length == 1
          @model.set 'expertId', suggestion.expert._id
          @model.set 'type', @request.get 'pricing'

        if @mget('expertId') == suggestion.expert._id
          suggestion.expert.selected = suggestion.expert
          selectedExpert = suggestion.expert
        suggestion

    if selectedExpert
      byType = selectedExpert.availability.byType[@mget('type')] || {}
      balance = byType.balance || 0
      selectedExpert.selectOptions = _.range(1, balance + 1).map (num) -> { num }

    if !@mget 'date' # default to today
      today = new Date().toJSON().slice(0, 10)
      @model.set 'date', today

    d = @model.extendJSON { available: suggested, selectedExpert, requestId: @model.requestId }
    @$el.html @tmpl d
    @
  renderSuccess: (model, response, options) =>
    window.location = "/adm/inbound/request/#{@request.get('_id')}"
  # TODO before merge use errorFormatter in requestCalls.coffee so we don't
  # need to do our own templating of error messages
  renderError: (model, response, options) =>
    @model.set 'errors', JSON.parse response.responseText

class exports.ScheduledView extends BB.BadassView
  logging: on
  el: '#edit'
  tmpl: require './templates/Scheduled'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    callId = @mget('callId') # set by router
    json = @model.toJSON() || {}
    call = _.find json.calls, (c) -> c._id == callId
    expert = _.find json.suggested, (s) -> s.expert._id == call.expertId

    d = _.extend call, {expert}
    console.log d
    @$el.html @tmpl d

module.exports = exports
