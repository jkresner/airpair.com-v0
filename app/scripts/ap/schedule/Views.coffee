exports          = {}
BB               = require 'BB'
M                = require './Models'
C                = require './Collections'
SV               = require '../../shared/Views'
calcExpertCredit = require 'lib/mix/calcExpertCredit'
parseYoutubeId   = require 'lib/mix/parseYoutubeId'
unschedule       = require 'lib/mix/unschedule'
storage          = require('../../shared/util').storage
objectId2Date    = require 'lib/mix/objectId2Date'

dateFormat = "DD MMM YYYY"
pickadateOptions = format: "dd mmm yyyy"
timepickerOptions = timeFormat: 'H:i'


class exports.CallsView extends BB.BadassView
  el: '#calls'
  tmpl: require './templates/CallRow'
  events:
    'click .edit': 'routeEdit'
  initialize: ->
    require('/scripts/providers/gapi')()
    @listenTo @model, 'change:calls', @render
  render: =>
    # $log 'RequestCallsView.render', gapi?
    if @model.get('calls').length == 0
      @$('#scheduled').html 'No calls scheduled'
    else
      if !gapi? then return setTimeout @render, 1000
      d = @model.toJSON()
      d.calls = d.calls.sort (a, b) -> a.datetime.localeCompare(b.datetime)
      @$('#scheduled').html('')
      for c in d.calls
        c.requestId = @model.id
        c.expert = @model.suggestion(c.expertId).expert
        @$('#scheduled').append @tmpl c
        @renderHangoutBtn(c) if $("##{c._id}").length > 0
  renderHangoutBtn: (c) =>
    hData =
      topic: @model.roomName(c.expert._id)
      render: 'createhangout'
      hangout_type: 'onair'
      invites: [{id:c.expert.email,invite_type:'EMAIL'},{'id':@model.contact(0).gmail,invite_type:'EMAIL'}]
      initial_apps: [{'app_id' : '140030887085', 'app_type' : 'LOCAL_APP' }]
      widget_size: 72
    # $log 'hData', hData
    gapi.hangout.render "#{c._id}", hData
  routeEdit: (e) =>
    cId = $(e.target).data('id')
    router.navTo "#{@model.id}/edit/#{cId}"
    false


class exports.ScheduleView extends BB.ModelSaveView
  # async: off
  el: '#schedule'
  tmpl: require './templates/Call'
  tmplA: require './templates/CallAvailable'
  tmplR: require './templates/Recording'
  viewData: ['duration', 'date', 'time', 'type']
  events:
    'click input:radio': (e) ->
      @model.set 'expertId', @$(e.target).val()
      @model.trigger 'change:id'
    'change [name=type]': ->
      @model.set 'type', @elm('type').val()
      @render()
    'change [name=inviteOwner]': ->
      storage 'inviteOwner', @elm('inviteOwner').is(':checked')
    'change [name=sendNotifications]': ->
      sendNotifications = @elm('sendNotifications').is(':checked')
      @model.set('sendNotifications', sendNotifications, silent: true)
    'input [name=youtube]': 'fetchYoutube'
    'click .deleteyoutube': 'deleteYoutube'
    'click .save': (e) ->
      $(e.target).attr 'disabled', true
      @save e
  initialize: ->
    @listenTo @model, 'change:id', @render
    @listenTo @collection, 'reset sync', @render
    @listenTo @videos, 'reset remove', @renderRecordings
  render: ->
    return if @collection.length == 0 || @request.get('suggested').length == 0
    if !@model.id?
      @renderAvailable()
    if @model.get('expertId')?
      d =
        expert: @request.suggestion(@model.get('expertId')).expert
        requestId: @request.id
        owner: @request.get('owner')
        inviteOwner: storage('inviteOwner') == 'true'

      if ! @model.has 'type'
        for ta in d.expert.credit.byTypeArray
          if ta.balance > 0
            @model.set 'type', ta.type

      if @model.id?
        orders = unschedule _.cloneDeep(@collection.toJSON()), @model.id
        d.time = moment(@model.get('datetime')).format('HH:mm')
        d.date = moment(@model.get('datetime')).format(dateFormat)
        d.expert.credit = calcExpertCredit orders, @model.get('expertId')
        d.expert.credit.byTypeArray = _.values(d.expert.credit.byType)
        balance = d.expert.credit.byType[@model.get('type')].balance
        d.expert.durationOptions = _.range(1, balance + 1)
      else
        # $log 'mode', @model.get('expertId'), d.expert.credit
        byType = d.expert.credit.byType[@mget('type')] || {}
        balance = byType.balance || 0
        d.expert.durationOptions = _.range(1, balance + 1)
        @model.set 'date', moment().format(dateFormat)  # default to today

      @$('.datepicker').stop()
      @$('.timepicker').timepicker('remove')
      # $log 'rendering', d
      @$el.html @tmpl @model.extendJSON d
      @$('.datepicker').pickadate(pickadateOptions)
      @$('.timepicker').timepicker(timepickerOptions)
    @
  renderAvailable: ->
    orders = @collection.toJSON()
    available = []
    for s in @request.get('suggested')
      expert = s.expert
      expert.credit = calcExpertCredit orders, expert._id
      expert.credit.byTypeArray = _.values(expert.credit.byType)

      if s.expert.credit.balance > 0
        available.push s

    if available.length == 1
      @model.set 'expertId', available[0].expert._id
      @$('.available').hide()
    # $log 'available', available.length
    @$('.available').html @tmplA {available}
    @
  renderRecordings: ->
    @$('.videolist').html('')
    for r in @videos.toJSON()
      details = r.data.liveStreamingDetails
      start = moment(details.actualStartTime)
      end = moment(details.actualEndTime)
      len = moment.duration(end.diff(start))
      details.actualLength = len.hours() + 'h ' + len.minutes() + 'm'
      @$('.videolist').append @tmplR r
    @
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.duration = parseInt d.duration
    d.inviteOwner = @elm('inviteOwner').is(':checked')
    d.sendNotifications = @elm('sendNotifications').is(':checked')
    d.recordings = @videos.toJSON()
    # $log 'getViewData', d
    d
  renderSuccess: (model, response, options) =>
    existing = _.find @request.get('calls'), (c) -> c._id == model.id
    if existing
      calls = _.without @request.get('calls'), existing
      calls.push model.attributes
      @request.set { calls }
      @$('.save').attr('disabled', false)
    else
      @request.silentReset model.attributes
      call = _.max model.get('calls'), (c) -> objectId2Date(c._id)
      @model.silentReset call
      @collection.fetch()
    @request.trigger 'change:calls'
  renderError: (model, response, options) ->
    @$('.save').attr('disabled', false)
    super model, response, options
  fetchYoutube: (e) ->
    youtubeId = parseYoutubeId(@elm('youtube').val())
    if youtubeId? && youtubeId != ''
      @elm('youtube').val('')
      @video.youtubeId = youtubeId
      @video.fetch success: (model) =>
        # $log 'vid', model.toJSON()
        @videos.updateAndReset data: model.toJSON(), type: 'youtube'
        @save()
  deleteYoutube: (e) ->
    youtubeId = $(e.target).data('id')
    recording = @videos.getByYoutubeId(youtubeId)
    @videos.remove recording
    @save()


module.exports = exports
