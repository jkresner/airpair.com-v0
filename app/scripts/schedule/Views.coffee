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
  events:
    'change input:radio': 'updateBalance' #todo get this to work
    'click #create': 'create'
  initialize: ->
    @listenTo @model, 'change', @render
    @render()

  render: ->
    console.log 'renderrrr', @model.attributes
    available = @model.get('suggested') || []
    available = available
      .filter (e) ->
        console.log(e.expertStatus)
        e.expertStatus == 'available'
      .map (e) ->
        e.balance = 3 # todo get balance from order object
        e
    @$el.html @tmpl { available }
    @

  updateBalance: (e) ->
    console.log('ub', e, this)

  create: (e) ->
    e.preventDefault()
    data = @getUserData()
    console.log 'create', e, this, data

    # todo save it
    # order = new M.Order(data)
    # order.save (err) ->
    #   if err then console.log err

  getUserData: ->
    expertId: $('input:radio:checked').val()
    duration: parseInt($('#duration').val(), 10)
    time: $('#date').val()

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
