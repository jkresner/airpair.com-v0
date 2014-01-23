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

class exports.ScheduledView extends BB.ModelSaveView
  # logging: on
  async: off
  el: '#edit'
  tmpl: require './templates/Scheduled'
  viewData: ['duration', 'date', 'time', 'type', 'notes']
  events:
    'click .save': 'save'
    'change .youtube': (e) ->
      inputs = $.makeArray(@$('.youtube')) # TODO consider adding this to BB
      recordings = inputs
        .map((el) -> $(el).val())
        .map(parseYoutubeId)
        .filter((x) -> x)
        .map((slug) -> { link: "https://youtu.be/#{slug}" })
      @model.set 'recordings', recordings

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

    call.recordingList = _.clone(call.recordings).map (r) ->
      id: parseYoutubeId(r.link)
    # for now, only allow one recording to be saved
    # call.recordingList.push { link: '' }

    d = _.extend call, { expert, requestId: @request.id }
    # console.log d
    @$('.datepicker').stop()
    @$el.html @tmpl d
    @$('.datepicker').pickadate()
    @

module.exports = exports
