
exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
##  To render requests rows for admin
#############################################################################

class exports.RequestRowView extends BB.BadassView
  tagName: 'tr'
  className: 'requestRow'
  tmpl: require './templates/Row'
  render: ->
    @$el.html @tmpl @tmplData()
    @
  tmplData: ->
    d = @model.toJSON()
    $log 'RequestRowView.tmplData', d
    _.extend d, {
      contactName:        d.company.contacts[0].fullName
      contactPic:         d.company.contacts[0].pic
      contactEmail:       d.company.contacts[0].email
      createdDate:        @model.createdDateString()
      suggestedCount:     d.suggested.length
      suggestedFitCount:  _.filter(d.suggested, (s) -> s.status is 'chosen').length
      callCount:          d.calls.length
      callCompleteCount:  _.filter(d.calls, (s) -> s.status is 'complete').length
    }


class exports.RequestsView extends BB.BadassView
  el: '#requests'
  tmpl: require './templates/Requests'
  initialize: (args) ->
    @listenTo @collection, 'sync', @render # filter sort
  render: ->
    @$el.html @tmpl( count: @collection.length )

    for m in @collection.models
      sts = m.get('status')
      @$("##{sts} tbody").append new exports.RequestRowView( model: m ).render().el
    @


#############################################################################
##  To edit request
#############################################################################


class MailTemplates
  tmplReceived: require './../../mail/customerRequestReceived'
  tmplReview: require './../../mail/customerRequestReview'
  tmplMatched: require './../../mail/customerRequestMatched'
  tmplFollowup: require './../../mail/customerRequestFollowup'
  constructor: (request) ->
    r = request.extendJSON tagsString: request.tagsString()

    @received = @tmplReceived r
    @review = @tmplReview r
    @matched = @tmplMatched r
    @followup = @tmplFollowup r


class exports.RequestInfoView extends BB.ModelSaveView
  el: '#info'
  tmpl: require './templates/RequestInfo'
  tmplCompany: require './templates/RequestInfoCompany'
  initialize: ->
    @$el.html @tmpl @model.toJSON()
    @$('#status').on 'change', @toggleCanceledIncompleteFields
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @listenTo @model, 'change', @render
  render: ->
    @setValsFromModel ['brief','availability','status','canceledReason','incompleteDetail','budget','pricing']
    mailTemplates = new MailTemplates @model
    tmplCompanyData = _.extend @mget('company'), { mailTemplates: mailTemplates, tagsString: @model.tagsString() }
    @$('#company-controls').html @tmplCompany(tmplCompanyData)
    @$('[data-toggle="popover"]').popover()
    @$('.status').addClass "label-#{@model.get('status')}"
    @$('.status').html @model.get('status')
    @
  toggleCanceledIncompleteFields: =>
    @$('#canceled-control-group').toggle @$('#status').val() == 'canceled'
    @$('#incomplete-control-group').toggle @$('#status').val() == 'incomplete'


class exports.RequestSuggestionsView extends BB.BadassView
  # logging: on
  el: '#suggestions'
  tmpl: require './templates/RequestSuggestions'
  tmplSuggestion: require './templates/RequestSuggestion'
  events:
    'click .add-suggestion': 'add'
    'click .js-tag': 'filterTag'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    @rTag = null
    if @model.get('tags')? && @model.get('tags').length
      @rTag = @model.get('tags')[0]
    @$el.html @tmpl @model.toJSON()
    @renderSuggestions()
    @
  renderSuggestions: ->
    if ! @rTag? then @$('.ops').html 'no tags on this request'
    else
      $log 'renderSuggestions', @rTag
      @$('.ops').html ''
      @$('li').removeClass 'active'
      @$("[data-short='#{@rTag.short}']").addClass 'active'

      suggested = _.pluck @model.get('suggested'), 'expert'
      @collection.filterFilteredModels( tag: @rTag, excludes: suggested )
      for s in @collection.filteredModels
        @$('.ops').append @tmplSuggestion(s.toJSON())
    @
  filterTag: (e) ->
    e.preventDefault()
    short = $(e.currentTarget).closest('li').data 'short'
    $log 'filterTag', short
    @rTag = _.find @model.get('tags'), (t) -> t.short == short
    @renderSuggestions()
  add: (e) ->
    expertId = $(e.currentTarget).data('id')
    expert = _.find @collection.filteredModels, (m) -> m.get('_id') == expertId
    if expert?
      # todo, check for duplicates
      @model.get('suggested').push
        status: 'waiting'
        expert: expert.toJSON()
        availability: []
      @parentView.save e


class exports.RequestSuggestedView extends BB.BadassView
  # logging: on
  el: '#suggested'
  tmpl: require './templates/RequestSuggested'
  mailTmpl: require './../../mail/expertRequestReview'
  events:
    'click .suggestDev': 'add'
    'click .deleteSuggested': 'remove'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    @$el.html '<legend>Suggested</legend>'
    suggested = @model.get 'suggested'
    if !suggested? then return
    else if suggested.length == 0
      @$el.append '<p>No suggestion made...</p>'
    else
      for s in @model.get 'suggested'

        mailData =
          _id: @model.id
          expertName: s.expert.name
          companyName: @mget('company').name

        s.body = @mailTmpl mailData
        s.tags =  @mget 'tags'
        s.expert.hasLinks = new M.Expert(s.expert).hasLinks()

        @$el.append @tmpl s
    @
  remove: (e) ->
    suggestionId = $(e.currentTarget).data 'id'
    toRemove = _.find @model.get('suggested'), (d) -> d._id == suggestionId
    $log 'suggestRemove', suggestionId, toRemove
    @model.set 'suggested', _.without( @model.get('suggested'), toRemove )
    @parentView.save e


class exports.RequestCallsView extends BB.BadassView
  tmpl: require './templates/RequestCalls'
  initialize: -> @listenTo @model, 'change', @render
  render: -> @$el.html @tmpl @model.toJSON()

class exports.RequestEventsView extends BB.BadassView
  tmpl: require './templates/RequestEvents'
  initialize: -> @listenTo @model, 'change', @render
  render: -> @$el.html @tmpl { events: @model.get('events').reverse() }

class exports.RequestNavView extends BB.BadassView
  tmpl: require './templates/RequestNav'
  initialize: -> @listenTo @model, 'change', @render
  render: -> @$el.html @tmpl @model.toJSON()


class exports.RequestView extends BB.ModelSaveView
  logging: on
  async: off
  el: '#request'
  tmpl: require './templates/Request'
  viewData: ['budget','pricing','status','availability','brief','canceledDetail','incompleteDetail']
  events:
    'click .save': 'save'
    'click .deleteRequest': 'deleteRequest'
  initialize: ->
    @$el.html @tmpl()
    @navView = new exports.RequestNavView el: '#requestNav', model: @model
    @eventsView = new exports.RequestEventsView el: '#events', model: @model
    @infoView = new exports.RequestInfoView model: @model, tags: @tags, parentView: @
    @suggestionsView = new exports.RequestSuggestionsView model: @model, collection: @experts, parentView: @
    @suggestedView = new exports.RequestSuggestedView model: @model, collection: @experts, parentView: @
    @callsView = new exports.RequestCallsView el: '#calls', model: @model, parentView: @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.fetch()
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.tags = @infoView.tagsInput.getViewData()
    d
  deleteRequest: ->
    @model.destroy wait: true, success: =>
      @collection.fetch success: => router.navTo 'list'
    false

Handlebars.registerPartial "RequestSet", require('./templates/RequestsSet')
Handlebars.registerPartial "MailSignature", require('./../../mail/signature')

module.exports = exports