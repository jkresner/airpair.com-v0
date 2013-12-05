exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

# <<<<<<< Updated upstream
# #############################################################################
# ##
# #############################################################################

# class exports.ListView extends BB.BadassView
#   el: '#list'
#   # tmpl: require './templates/Welcome'
#   # events: { 'click .track': 'track' }
#   # initialize: ->
#   #   @e = addjs.events.customerLogin
#   #   @e2 = addjs.events.customerWelcome
#   # render: ->
#   #   if !@timer? then @timer = new addjs.Timer(@e.category).start()
#   #   @$el.html @tmpl()
#   #   trackWelcome = => addjs.trackEvent @e2.category, @e2.name, @e2.uri, 0
#   #   setTimeout trackWelcome, 400

# =======
# schedule form
class exports.ScheduleFormView extends BB.ModelSaveView
  # todo
  logging: on
  el: '#scheduleForm'
  tmpl: require './templates/ScheduleForm'
  events:
    'click .save': 'save'
    'keyup .expert input': 'updateDuration'
  initialize: ->
    @listenTo @model, 'change', @render
    @render()

  render: ->
    # todo stuff
    console.log 'renderrrr', @model.attributes

    experts = @model.get('suggested') || []
    experts = experts.filter (e) ->
      e.expertStatus == 'available'

    @$el.html @tmpl { experts }
    @renderBalance()
    @

  renderBalance: ->
    experts = @model.get('suggested')
    if !experts then return

    reducer = (prev, cur) ->
      prev + (cur.duration || 0)

    balance = experts.reduce reducer, 0
    hours = parseInt(@model.get('hours'), 10)
    @$el.find('#balance').text balance
    @$el.find('#hours').text hours

    if balance > hours
      return @$el.find('#warning').show()
    @$el.find('#warning').hide()

  # todo only allow numbers
  updateDuration: _.debounce ((e) ->
    el = $ e.currentTarget
    id = el.attr 'data-expertId'
    duration = parseInt(el.val(), 10)

    sug = @model.get 'suggested'
    expertIndex = -1
    expert = sug.some (e, i) ->
      expertIndex = i
      e._id == id

    # do nothing if it is not changing
    if duration == sug[expertIndex].duration
      return

    if isNaN(duration) || !isFinite(duration) || duration < 0
      duration = 0

    console.log('updateduration', id, duration)
    el.val(duration)
    sug[expertIndex].duration = duration
    @model.set 'suggested', sug
    @renderBalance()
  ), 250

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
