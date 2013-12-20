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
  viewData: ['duration', 'date']
  events:
    'change input:radio': 'updateBalance' #todo get this to work
    'click #create': 'save'
  initialize: ->
    @listenTo @request, 'change', @render
    @listenTo @collection, 'sync', @render
    @listenTo @model, 'change', @render

  render: ->
    suggested = @request.get('suggested') || []
    orders = @collection.toJSON()
    suggested = suggested
      .filter (suggestion) ->
        suggestion.expertStatus == 'available'
      .map (suggestion) ->
        availability = expertAvailability orders, suggestion.expert._id
        suggestion.expert.balance = availability.expertBalance
        suggestion

    d = @model.extendJSON { available: suggested, requestId: @model.requestId }
    @$el.html @tmpl d
    @

  updateBalance: (e) ->
    @model.set 'expertId', @elm('expertId').val()

    console.log 'ub', @elm('expertId').val(), e, @
    # @elm('type')
    # @elm('duration')

  # create: (e) ->
  #   e.preventDefault()
  #   requestCall = new M.RequestCall @getViewData()
  #   requestCall.requestId = @model.get('_id')
  #   requestCall.save()

  getViewData: ->
    callData = @getValsFromInputs @viewData
    # callData.expertId = $('input:radio:checked').val()
    $log 'callData', callData
    callData

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
