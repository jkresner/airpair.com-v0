exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

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
    @render()

  render: ->
    available = @model.get('suggested') || []
    available = available
      .filter (e) ->
        e.expertStatus == 'available'
      .map (e) ->
        e.balance = 3 # todo get balance from order object
        e
    @$el.html @tmpl { available, _id: @model.get('_id') }
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
