exports          = {}
BB               = require '../../lib/BB'
M                = require './Models'
C                = require './Collections'
SV               = require '../shared/Views'
calcExpertCredit = require '../shared/mix/calcExpertCredit'
parseYoutubeId   = require '../shared/mix/parseYoutubeId'
unschedule       = require '../shared/mix/unschedule'
storage          = require('../util').storage

dateFormat = "DD MMM YYYY"
pickadateOptions =
  format: "dd mmm yyyy"
timepickerOptions =
  timeFormat: 'H:i'

class exports.CallScheduleView extends BB.ModelSaveView
  async: off
  el: '#scheduleForm'
  tmpl: require './templates/CallSchedule'
  viewData: ['duration', 'date', 'time', 'type', 'timezone']
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
      isAdmin: @isAdmin

    @$('.datepicker').stop()
    @$('.timepicker').timepicker('remove')
    if !@isAdmin then @timezoneInputView?.cleanTypehead()
    @$el.html @tmpl @model.extendJSON d
    @$('.datepicker').pickadate(pickadateOptions)
    @$('.timepicker').timepicker(timepickerOptions)
    if !@isAdmin then @timezoneInputView = new exports.TimezoneInputView()
    @
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.inviteOwner = @elm('inviteOwner').is(':checked')
    d.sendNotifications = @elm('sendNotifications').is(':checked')
    d
  renderSuccess: (model, response, options) =>
    if @isAdmin
      return window.location = "/adm/inbound/request/#{@request.get('_id')}"
    window.location = "/review/#{@request.get('_id')}"
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
    'click .delete': (e) ->
      $(e.target).attr('disabled', true)
      @model.destroy(wait: true, success: @renderSuccess, error: @renderError)
      false
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
    window.location = "/adm/inbound/request/#{@request.get('_id')}"
  renderError: (model, response, options) ->
    @$('.save').attr('disabled', false)
    super model, response, options

#
# show the expert calls that need an RSVP
#
class exports.ExpertCallRowView extends BB.ModelSaveView
  tagName: 'div'
  tmpl: require './templates/ExpertCallRow'
  initialize: ->
    @listenTo @model, 'change', @render
    @
  render: ->
    d = @model.toJSON()
    # if d.gcal then d.status = 'confirmed' # TODO uncomment
    @$el.html @tmpl d
    @

class exports.CallsView extends BB.ModelSaveView
  el: '#calls'
  initialize: ->
    @listenTo @collection, 'reset', @render
  render: ->
    for m in @collection.models
      @$el.append new exports.ExpertCallRowView( model: m ).render().el

class exports.TimezoneInputView extends BB.HasBootstrapErrorStateView
  el: '#timezoneInput'
  # tmpl: require './templates/TimezoneInput'
  tmplResult: require './templates/TypeAheadResult'
  initialize: (args) ->
    # @$el.append @tmpl() # TODO user model has a saved timezone
    @initTypehead()
  render: ->
    @
  initTypehead: =>
    names = []
    now = moment()
    col = _.each window.ap_timezones.zones, (value, key) ->
      names.push
        name: key
        # TODO compute the offsets to show at the end.
        # tz: now.tz(key).format('[GMT]Z')

    @cleanTypehead().val('').show()
    @$el.typeahead(
      header: '<header><strong>&nbsp;&nbsp;Timezones</strong></header>'
      noresultsHtml: '&nbsp;&nbsp;No results'
      name: 'collection' + new Date().getTime()
      valueKey: 'name'
      template: @tmplResult
      local: names
    ).on('typeahead:selected', @select)
    @
  select: (e, data) =>
    if e then e.preventDefault()
    console.log 'select', data
  cleanTypehead: ->
    @$el.typeahead('destroy').off 'typeahead:selected'
  getViewData: ->
    @$el.val()

module.exports = exports
