exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'
expertCredit = require '../shared/mix/expertCredit'
parseYoutubeId = require '../shared/mix/parseYoutubeId'

# schedule form
class exports.ScheduleFormView extends BB.ModelSaveView
  async: off
  el: '#scheduleForm'
  tmpl: require './templates/ScheduleForm'
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
    if router.editpage then return # we are on the editing page

    orders = @collection.toJSON()
    selectedExpert = null
    suggested = @request.get('suggested') || []
    suggested = suggested
      .map (suggestion) =>
        expert = suggestion.expert
        expert.credit = expertCredit orders, expert._id
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
      today = new Date().toJSON().slice(0, 10)
      @model.set 'date', today

    d = @model.extendJSON { available: suggested, selectedExpert, requestId: @request.get('_id') }
    @$('.datepicker').stop()
    @$el.html @tmpl d
    @$('.datepicker').pickadate()
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

class exports.VideosView extends BB.HasBootstrapErrorStateView
  el: '#videos'
  form: require './templates/videoForm'
  tmpl: require './templates/videoList'
  events:
    'click .fetch': 'fetch'
    'click .delete': 'delete'
  initialize: ->
    @recordings = @requestCall.get('recordings')
    @$el.html @form()
    @render()
  render: ->
    data = @recordings.map (r) ->
      details = r.data.liveStreamingDetails
      start = moment(details.actualStartTime)
      end = moment(details.actualEndTime)
      len = moment.duration(end.diff(start))
      details.actualLength = len.hours() + ':' + len.minutes()
      r
    @$('.list').html @tmpl { recordings: data }
  fetch: (e) ->
    e.preventDefault()
    el = $(e.target)
    el.attr('disabled', true)
    input = @elm('youtube')
    youtubeId = parseYoutubeId(input.val())
    if !youtubeId then return

    $.ajax("/api/videos/youtube/#{youtubeId}")
      .done (videoData, b, c) =>
        if !videoData.id
          return @tryRenderInputInvalid 'youtube',
            "video is private, or http://youtu.be/#{youtubeId} doesn't exist"
        input.val('')
        @_upsertRecording(videoData)
        @render()
      .always =>
        el.attr('disabled', false)
  # takes some videoData, upserts it into the recording list
  _upsertRecording: (videoData) ->
    youtubeId = videoData.id
    found = false
    for r, i in @recordings
      if r.data.id == youtubeId
        @recordings[i].data = videoData
        found = true
    if !found then @recordings.push { data: videoData, type: 'youtube' }
  delete: (e) ->
    youtubeId = $(e.target).data('id')
    # keep only those that dont match the id
    @recordings = _.filter @recordings, (r) -> r.data.id != youtubeId
    @render()

class exports.ScheduledView extends BB.ModelSaveView
  # logging: on
  async: off
  el: '#edit'
  tmpl: require './templates/Scheduled'
  viewData: ['date', 'time', 'type', 'notes']
  events:
    'click .save': '_save'
  initialize: ->
    @listenTo @request, 'change', @render
    @listenTo @collection, 'reset', @render
    @listenTo @model, 'change', @render

  render: ->
    if !router.editpage then return # we are on the scheduling page

    call = @model.toJSON()
    expert = @request.suggestion(call.expertId).expert

    # open source / private / nda dropdown
    # orders = @collection.toJSON()
    # expert.credit = expertCredit orders, call.expertId
    # expert.credit.byType[call.type].selected = true
    # expert.credit.byTypeArray = _.values(expert.credit.byType)

    # a partial time according to the RFC 3389.
    # TODO include the .zone() function so it will be PST everywhere
    call.time = moment(call.datetime).format('HH:mm')
    call.date = moment(call.datetime).format('YYYY-MM-DD')

    # hours dropdown
    # tricky: take into account the call's current duration!
    # byType = expert.credit.byType[@model.get('type')] || {}
    # balance = byType.balance || 0
    # expert.selectOptions = _.range(1, balance + 1).map (num) -> { num }
    # (expert.selectOptions[call.duration - 1] || {}).selected = true

    # TODO call.status

    d = _.extend call, { expert, requestId: @request.id }
    @$('.datepicker').stop()
    @$el.html @tmpl d
    @$('.datepicker').pickadate()

    # ScheduledView re-renders all the time, so we construct VideosView here,
    # when we know that the DOM elements exist.
    @videosView = new exports.VideosView { requestCall: @model }
    @
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.recordings = @videosView.recordings
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
