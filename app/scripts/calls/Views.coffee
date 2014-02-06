exports = {}
BB = require '../../lib/BB'
M = require './Models'
C = require './Collections'
SV = require '../shared/Views'
calcExpertCredit = require '../shared/mix/calcExpertCredit'
parseYoutubeId = require '../shared/mix/parseYoutubeId'
unschedule = require '../shared/mix/unschedule'

pickadateOptions =
  format: "dd mmm 'yy"

dateFormat = "DD MMM 'YY"

class exports.CallScheduleView extends BB.ModelSaveView
  async: off
  el: '#scheduleForm'
  tmpl: require './templates/CallSchedule'
  viewData: ['duration', 'date', 'time', 'type']
  events:
    'click input:radio': (e) ->
      @model.set 'expertId', @$(e.target).val()
      @model.set 'type', @elm('type').val()
    'blur [name=type]': -> @model.set 'type', @elm('type').val()
    'change [name=duration]': -> @model.set 'duration', parseInt(@elm('duration').val(), 10), silent: true
    'blur [name=date]': -> @model.set 'date', @elm('date').val(), silent: true
    'blur [name=time]': -> @model.set 'time', @elm('time').val(), silent: true
    'click .save': '_save'
  initialize: ->
    @listenTo @request, 'change', @render
    @listenTo @collection, 'reset', @render
    @listenTo @model, 'change', @render

  render: ->
    orders = @collection.toJSON()
    selectedExpert = null
    suggested = @request.get('suggested') || []
    suggested = suggested
      .map (suggestion) =>
        expert = suggestion.expert
        expert.credit = calcExpertCredit orders, expert._id
        expert.credit.byTypeArray = _.values(expert.credit.byType)
        suggestion

      # expert is available, you can only purchase hours for someone available
      .filter (suggestion) =>
        suggestion.expert.credit.balance > 0

      .map (suggestion, __, filtered) =>
        # selects the first expert by default when there's only one
        if filtered.length == 1
          @model.set 'expertId', suggestion.expert._id
          if !@model.get 'type'
            @model.set 'type', suggestion.expert.credit.byTypeArray[0].type

        if @mget('expertId') == suggestion.expert._id
          suggestion.expert.selected = suggestion.expert
          selectedExpert = suggestion.expert
        else suggestion.expert.selected = undefined
        suggestion

    if selectedExpert
      byType = selectedExpert.credit.byType[@mget('type')] || {}
      balance = byType.balance || 0
      selectedExpert.selectOptions = _.range(1, balance + 1).map (num) -> { num }

    if !@mget 'date' # default to today
      today = moment().format(dateFormat)
      @model.set 'date', today

    d = @model.extendJSON { available: suggested, selectedExpert, requestId: @request.get('_id') }
    @$('.datepicker').stop()
    @$el.html @tmpl d
    @$('.datepicker').pickadate(pickadateOptions)
    @
  # prevents double-saves, provides feedback that request is in progress.
  _save: (e) ->
    $(e.target).attr('disabled', true)
    @save e
  renderSuccess: (model, response, options) =>
    window.location = "/adm/inbound/request/#{@request.get('_id')}"
  renderError: (model, response, options) ->
    @$('.save').attr('disabled', false)
    super model, response, options

# this view is very similar to TagsInputView & MarketingTagsInputView
# it is it's own component, and doesn't care much about the parent view.
class exports.VideosView extends BB.ModelSaveView
  el: '#videos'
  tmplForm: require './templates/VideoForm'
  tmpl: require './templates/VideoList'
  events:
    'click .fetch': 'fetch'
    'click .delete': 'delete'
  initialize: ->
    @requestCall.once 'change:recordings', =>
      @collection.set @requestCall.get('recordings')
    @listenTo @collection, 'reset add remove', @render
    @$el.html @tmplForm()
  render: ->
    recordings = @collection.toJSON().map (r) ->
      details = r.data.liveStreamingDetails
      start = moment(details.actualStartTime)
      end = moment(details.actualEndTime)
      len = moment.duration(end.diff(start))
      details.actualLength = len.hours() + 'h ' + len.minutes() + 'm'
      r
    @$('.list').html @tmpl { recordings }
    @
  fetch: (e) ->
    e.preventDefault()
    @renderInputsValid()
    input = @elm('youtube')
    youtubeId = parseYoutubeId(input.val())
    if !youtubeId then return
    $(e.target).attr('disabled', true)
    input.val(youtubeId)
    @model.youtubeId = youtubeId
    @model.fetch { success: @renderSuccess, error: @renderError }
  renderSuccess: (model, response, options) =>
    @$('.fetch').attr('disabled', false)
    @elm('youtube').val('')
    recording = { data: @model.toJSON(), type: 'youtube' }
    existing = @collection.getByYoutubeId(recording.data.id)
    if existing then return existing.set recording
    @collection.add recording
  renderError: (model, response, options) =>
    @$('.fetch').attr('disabled', false)
    super model, response, options
  delete: (e) ->
    youtubeId = $(e.target).data('id')
    recording = @collection.getByYoutubeId(youtubeId)
    @collection.remove recording

class exports.CallEditView extends BB.ModelSaveView
  async: off
  el: '#edit'
  tmpl: require './templates/CallEdit'
  viewData: ['duration', 'date', 'time', 'type', 'notes']
  events:
    'click .save': '_save'
  initialize: ->
    # orders and request are already set by the time the router sets the model
    @listenTo @model, 'change', @render
  render: ->
    call = @model.toJSON()
    expert = @request.suggestion(call.expertId).expert
    orders = @collection.toJSON()
    orders = unschedule orders, call._id

    # TODO include the .zone() function so it will be PST everywhere
    call.time = moment(call.datetime).format('HH:mm')
    call.date = moment(call.datetime).format(dateFormat)

    # TODO open source / private / nda dropdown
    expert.credit = calcExpertCredit orders, call.expertId
    # expert.credit.byTypeArray = _.values(expert.credit.byType)

    # hours dropdown
    balance = expert.credit.byType[call.type].balance
    expert.selectOptions = _.range(1, balance + 1).map (num) -> { num }

    # TODO call.status
    d = _.extend call, { expert, requestId: @request.id }
    @$('.datepicker').stop()
    @$('#callEdit').html @tmpl d
    @$('.datepicker').pickadate(pickadateOptions)
    @
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.sendNotifications = @elm('sendNotifications').is(':checked')
    d.recordings = @videos.toJSON()
    d
  # prevents double-saves, provides feedback that request is in progress.
  _save: (e) ->
    $(e.target).attr('disabled', true)
    @save e
  renderSuccess: (model, response, options) =>
    window.location = "/adm/inbound/request/#{@request.get('_id')}"
  renderError: (model, response, options) ->
    @$('.save').attr('disabled', false)
    super model, response, options

module.exports = exports
