exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'
expertAvailability = require '../shared/mix/expertAvailability'
parseYoutubeId = require '../shared/mix/parseYoutubeId'

# schedule form
class exports.ScheduleFormView extends BB.ModelSaveView
  # logging: on
  el: '#scheduleForm'
  tmpl: require './templates/ScheduleForm'
  viewData: ['duration', 'date', 'time', 'type']
  events:
    'click input:radio': (e) ->
      @model.set 'expertId', @$(e.target).val()
      @model.set 'type', @elm('type').val()
    'change [name=type]': -> @model.set 'type', @elm('type').val()
    'change [name=duration]': -> @model.set 'duration', parseInt(@elm('duration').val(), 10)
    'blur [name=date]': -> @model.set 'date', @elm('date').val()
    'blur [name=time]': -> @model.set 'time', @elm('time').val()
    'click .save': '_save'
  initialize: ->
    if @request.get('callId') then return # we are on the editing page
    @listenTo @request, 'change', @render
    @listenTo @collection, 'reset', @render
    @listenTo @model, 'change', @render

  render: ->
    if !@request.get('userId') then return

    orders = @collection.toJSON()
    selectedExpert = null
    suggested = @request.get('suggested') || []
    suggested = suggested
      .map (suggestion) =>
        expert = suggestion.expert
        expert.availability = expertAvailability orders, expert._id
        expert.availability.byTypeArray = _.values(expert.availability.byType)
        suggestion

      # expert is available, you can only purchase hours for someone available
      .filter (suggestion) =>
        suggestion.expert.availability.balance > 0

      .map (suggestion, __, filtered) =>
        # selects the first expert by default when there's only one
        if filtered.length == 1
          @model.set 'expertId', suggestion.expert._id
          @model.set 'type', suggestion.expert.availability.byTypeArray[0].type

        if @mget('expertId') == suggestion.expert._id
          suggestion.expert.selected = suggestion.expert
          selectedExpert = suggestion.expert
        else suggestion.expert.selected = undefined
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

    d = @model.extendJSON { available: suggested, selectedExpert, requestId: @request.get('_id') }

    @$('.datepicker').stop()
    @$('.timepicker').stop()
    @$el.html @tmpl d
    @$('.datepicker').pickadate()
    @$('.timepicker').pickatime({ format: 'HH:i', formatLabel: 'HH:i' })
    @
  # prevents double-saves, provides feedback that request is in progress.
  _save: (e) ->
    $(e.target).attr('disabled', true)
    @save e
  renderSuccess: (model, response, options) =>
    window.location = "/adm/inbound/request/#{@request.get('_id')}"

# class exports.ScheduledView extends BB.ModelSaveView
#   logging: on
#   el: '#edit'
#   tmpl: require './templates/Scheduled'
#   viewData: ['duration', 'date', 'time', 'type', 'notes']
#   events:
#     'click .save': 'save'
#     'change .youtube': (e) ->
#       inputs = $.makeArray(@$('.youtube')) # TODO consider adding this to BB
#       recordings = inputs
#         .map((el) -> $(el).val())
#         .map(parseYoutubeId)
#         .filter((x) -> x)
#         .map((slug) -> { link: "https://youtu.be/#{slug}" })
#       @model.set 'recordings', recordings

#   initialize: ->
#     if !@request.get('callId') then return # we are on the create page

#     @listenTo @request, 'change', @render
#     @listenTo @collection, 'reset', @render
#     @listenTo @model, 'change', @render

#     # the @model is the requestCall, and we use it only for saving / updating,
#     # but we need to populate it with existing data from the request.
#     @request.once 'change', =>
#       callId = @request.get('callId') # set by router
#       json = @request.toJSON()
#       @model.set _.find json.calls, (c) -> c._id == callId

#   render: ->
#     if @collection.isEmpty() then return
#     call = @model.toJSON()
#     expert = @request.suggestion(call.expertId).expert

#     # open source / private / nda dropdown
#     orders = @collection.toJSON()
#     expert.availability = expertAvailability orders, call.expertId
#     expert.availability.byType[call.type].selected = true
#     expert.availability.byTypeArray = _.values(expert.availability.byType)

#     # a partial time according to the RFC 3389.
#     # TODO include the .zone() function so it will be PST everywhere
#     call.time = moment(call.datetime).format('HH:mm:ss')
#     call.date = moment(call.datetime).format('YYYY-MM-DD')

#     # hours dropdown
#     # tricky: take into account the call's current duration!
#     byType = expert.availability.byType[@model.get('type')] || {}
#     balance = byType.balance || 0
#     expert.selectOptions = _.range(1, balance + 1).map (num) -> { num }
#     (expert.selectOptions[call.duration - 1] || {}).selected = true

#     # status
#     # TODO bad match, cancelled.
#     # TODO use server-side VALID_CALL_TYPES enum
#     expert.statuses = [ 'pending', 'scheduled', 'completed' ].map (status) ->
#       selected = call.status == status
#       { status, selected }

#     # TODO remove default value
#     call.recordings = call.recordings.length || [ 'http://www.youtube.com/watch?v=aANmpDSTcXI&otherjunkparams', 'youtu.be/aANmpDSTcXI' , 'aANmpDSTcXI'].map((link) -> {link: link})
#     call.recordingList = _.clone(call.recordings)
#     call.recordingList.push { link: '' }

#     d = _.extend call, { expert }
#     @$el.html @tmpl d
#     @

module.exports = exports
