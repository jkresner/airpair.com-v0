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
    'click #create': 'create'
  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @collection, 'sync', @render
    @render()

  render: ->
    suggested = @model.get('suggested') || []
    orders = @collection.toJSON()
    suggested = suggested
      .filter (suggestion) ->
        suggestion.expertStatus == 'available'
      .map (suggestion) ->
        availability = expertAvailability orders, suggestion.expert._id
        suggestion.expert.balance = availability.expertBalance
        suggestion
    @$el.html @tmpl { available: suggested, _id: @model.get('_id') }
    @

  updateBalance: (e) ->
    console.log('ub', e, this)

  create: (e) ->
    e.preventDefault()
    requestCall = new M.RequestCall @getViewData()
    requestCall.requestId = @model.get('_id')
    requestCall.save()

  getViewData: ->
    callData = @getValsFromInputs @viewData
    callData.expertId = $('input:radio:checked').val()
    callData

class exports.ScheduledView extends BB.BadassView
  # todo
  logging: on
  el: '#scheduled'
  tmpl: require './templates/Scheduled'
  initialize: ->
    @listenTo @model, 'change', @render
    @render()
  render: ->

module.exports = exports
