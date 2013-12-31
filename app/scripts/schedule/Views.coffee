exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'
expertAvailability = require '../shared/mix/expertAvailability'

# schedule form
class exports.ScheduleFormView extends BB.ModelSaveView
  logging: on
  el: '#scheduleForm'
  tmpl: require './templates/ScheduleForm'
  viewData: ['duration', 'date', 'time', 'expertId', 'type']
  events:
    'click input:radio': (e) ->
      @model.set 'expertId', @$(e.target).val()
      @model.set 'type', @elm('type').val()
    'change [name=type]': -> @model.set 'type', @elm('type').val()
    'change [name=duration]': -> @model.set 'duration', parseInt(@elm('duration').val(), 10)
    'blur [name=date]': -> @model.set 'date', @elm('date').val()
    'blur [name=time]': -> @model.set 'time', @elm('time').val()
    'click #create': 'save'
  initialize: ->
    if @request.get('callId') then return # we are on the editing page
    @listenTo @request, 'change', @render
    @listenTo @collection, 'sync', @render
    @listenTo @model, 'change', @render

  render: ->
    if @collection.isEmpty() || !@request.get('userId') then return

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
      # don't forget their choice upon rerender
      (selectedExpert.selectOptions[@model.get('duration') - 1] || {}).selected = true

    if !@mget 'date' # default to today
      today = new Date().toJSON().slice(0, 10)
      @model.set 'date', today

    d = @model.extendJSON { available: suggested, selectedExpert, requestId: @request._id }
    @$el.html @tmpl d
    @
  renderSuccess: (model, response, options) =>
    window.location = "/adm/inbound/request/#{@request.get('_id')}"
  # TODO before merge use errorFormatter in requestCalls.coffee so we don't
  # need to do our own templating of error messages
  renderError: (model, response, options) =>
    @model.set 'errors', JSON.parse response.responseText

parseYoutubeId = (str) ->
  str = str.trim()
  variable = '([a-zA-Z0-9_]*)'
  # e.g. http://www.youtube.com/watch?v=aANmpDSTcXI&otherjunkparams
  id = str.match("v=#{variable}")?[1]
  if id then return id

  # e.g. youtu.be/aANmpDSTcXI
  id = str.match("youtu\.be/#{variable}")?[1]
  if id then return id

  # e.g. aANmpDSTcXI
  str.match("^#{variable}$")?[1]

class exports.ScheduledView extends BB.ModelSaveView
  logging: on
  el: '#edit'
  tmpl: require './templates/Scheduled'
  viewData: ['duration', 'date', 'time', 'type', 'notes']
  events:
    'click #update': 'save'
    'change .youtube': (e) ->
      inputs = $.makeArray(@$('.youtube')) # TODO consider adding this to BB
      recordings = inputs
        .map((el) -> $(el).val())
        .map(parseYoutubeId)
        .filter((x) -> x)
      @model.set 'recordings', recordings

  initialize: ->
    if !@request.get('callId') then return # we are on the create page

    @listenTo @request, 'change', @render
    @listenTo @collection, 'sync', @render
    @listenTo @model, 'change', @render

    # the @model is the requestCall, and we use it only for saving / updating,
    # but we need to populate it with existing data from the request.
    @request.once 'change', =>
      callId = @request.get('callId') # set by router
      json = @request.toJSON()
      @model.set _.find json.calls, (c) -> c._id == callId

  render: ->
    if @collection.isEmpty() then return
    call = @model.toJSON()
    console.log('render')
    suggested = @request.get('suggested') || {}
    suggestion = _.find suggested, (s) -> s.expert._id == call.expertId
    expert = suggestion.expert

    # open source / private / nda dropdown
    orders = @collection.toJSON()
    expert.availability = expertAvailability orders, call.expertId
    expert.availability.byType[call.type].selected = true
    expert.availability.byTypeArray = _.values(expert.availability.byType)

    # a partial time according to the RFC 3389.
    # TODO include the .zone() function so it will be PST everywhere
    call.time = moment(call.datetime).format('HH:mm:ss')
    call.date = moment(call.datetime).format('YYYY-MM-DD')

    # hours dropdown
    # tricky: take into account the call's current duration!
    byType = expert.availability.byType[@model.get('type')] || {}
    balance = byType.balance || 0
    expert.selectOptions = _.range(1, balance + 1).map (num) -> { num }
    (expert.selectOptions[call.duration - 1] || {}).selected = true

    # status
    # TODO bad match, cancelled.
    # TODO use server-side VALID_CALL_TYPES enum
    expert.statuses = [ 'pending', 'scheduled', 'completed' ].map (status) ->
      selected = call.status == status
      { status, selected }

    # TODO remove
    call.recordings = call.recordings.length || [ 'http://www.youtube.com/watch?v=aANmpDSTcXI&otherjunkparams', 'youtu.be/aANmpDSTcXI' , 'aANmpDSTcXI']
    call.recordingList = call.recordings.map (link) -> { link }
    call.recordingList.push { link: '' }

    d = _.extend call, { expert }
    console.log d
    @$el.html @tmpl d
    @

module.exports = exports
