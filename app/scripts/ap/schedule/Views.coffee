exports          = {}
BB               = require 'BB'
M                = require './Models'
C                = require './Collections'
SV               = require '../../shared/Views'
calcExpertCredit = require 'lib/mix/calcExpertCredit'
parseYoutubeId   = require 'lib/mix/parseYoutubeId'
unschedule       = require 'lib/mix/unschedule'
storage          = require('../../shared/util').storage

dateFormat = "DD MMM YYYY"
pickadateOptions = format: "dd mmm yyyy"
timepickerOptions = timeFormat: 'H:i'


class exports.CallsView extends BB.BadassView
  el: '#calls'
  # logging: on
  tmplCall: require './templates/RequestCall'
  tmpl: require './templates/RequestCalls'
  initialize: ->
    require('/scripts/providers/gapi')()
    @listenTo @model, 'change:calls', @render
  render: =>
    $log 'RequestCallsView.render', gapi?
    if !gapi? then return setTimeout @render, 1000
    d = @model.toJSON()
    d.calls = d.calls.sort (a, b) -> a.datetime.localeCompare(b.datetime)
    d.calls = d.calls.map (call) =>
      call.expert = @model.suggestion(call.expertId).expert
      call
    @$el.html @tmpl d
    for c in d.calls
      @$('#scheduled').append @tmplCall c
      if $("##{c._id}").length > 0
        hData =
          topic: @model.roomName c.expert._id
          render: 'createhangout'
          hangout_type: 'onair'
          invites: [{id:c.expert.email,invite_type:'EMAIL'},{'id':@model.contact(0).gmail,invite_type:'EMAIL'}]
          initial_apps: [{'app_id' : '140030887085', 'app_type' : 'LOCAL_APP' }]
          widget_size: 72
        # $log 'hData', hData
        gapi.hangout.render "#{c._id}", hData



class exports.ScheduleView extends BB.ModelSaveView
  # async: off
  el: '#schedule'
  tmpl: require './templates/CallSchedule'
  viewData: ['duration', 'date', 'time', 'type']
  events:
    'click input:radio': (e) ->
      @model.set 'expertId', @$(e.target).val()
      @model.set 'type', @elm('type').val()
    'blur [name=type]': -> @model.set 'type', @elm('type').val()
    'change [name=duration]': ->
      @model.set 'duration', parseInt(@elm('duration').val(), 10), silent: true
    'blur [name=date]': -> @model.set 'date', @elm('date').val(), silent: true
    'blur [name=time]': -> @model.set 'time', @elm('time').val(), silent: true
    'change [name=inviteOwner]': ->
      storage 'inviteOwner', @elm('inviteOwner').is(':checked')
    'change [name=sendNotifications]': ->
      sendNotifications = @elm('sendNotifications').is(':checked')
      @model.set('sendNotifications', sendNotifications, silent: true)
    'click .save': (e) ->
      $(e.target).attr('disabled', true)
      @save(e)
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

        if @mget('expertId') == suggestion.expert._id
          suggestion.expert.selected = suggestion.expert
          selectedExpert = suggestion.expert
          if !@mget 'type'
            @model.set 'type', suggestion.expert.credit.byTypeArray[0].type
        else suggestion.expert.selected = undefined
        suggestion

    if selectedExpert
      byType = selectedExpert.credit.byType[@mget('type')] || {}
      balance = byType.balance || 0
      selectedExpert.selectOptions = _.range(1, balance + 1)

    if !@mget 'date' # default to today
      today = moment().format(dateFormat)
      @model.set 'date', today

    d =
      available: suggested
      selectedExpert: selectedExpert
      requestId: requestId = @request.get('_id')
      owner: @request.get('owner')
      inviteOwner: storage('inviteOwner') == 'true'

    @$('.datepicker').stop()
    @$('.timepicker').timepicker('remove')
    @$el.html @tmpl @model.extendJSON d
    @$('.datepicker').pickadate(pickadateOptions)
    @$('.timepicker').timepicker(timepickerOptions)
    @
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.inviteOwner = @elm('inviteOwner').is(':checked')
    d.sendNotifications = @elm('sendNotifications').is(':checked')
    d
  renderSuccess: (model, response, options) =>
    window.location = "/adm/pipeline/request/#{@request.get('_id')}"
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
    'click .save': (e) ->
      $(e.target).attr('disabled', true)
      @save(e)
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
    expert.selectOptions = _.range(1, balance + 1)

    # TODO call.status
    d = _.extend call, { expert, requestId: @request.id }
    @$('.datepicker').stop()
    @$('.timepicker').timepicker('remove')
    @$('#callEdit').html @tmpl d
    @$('.datepicker').pickadate(pickadateOptions)
    @$('.timepicker').timepicker(timepickerOptions)
    @
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.sendNotifications = @elm('sendNotifications').is(':checked')
    d.recordings = @videos.toJSON()
    d
  renderSuccess: (model, response, options) =>
    window.location = "/adm/pipeline/request/#{@request.get('_id')}"
  renderError: (model, response, options) ->
    @$('.save').attr('disabled', false)
    super model, response, options

module.exports = exports
