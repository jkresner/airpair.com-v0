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
    # $log 'RequestRowView.tmplData', d
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


class exports.RequestFormInfoCompanyView extends BB.ModelSaveView
  # logging: on
  el: '#company-controls'
  tmpl: require './templates/RequestFormCompanyInfo'
  mailTmpl: require './../../mail/customerRequestReview'
  initialize: ->
  render: ->
    body = @mailTmpl(_id: @model.id)
    tmplData = _.extend @model.get('company'), { body: body }
    $log 'tempData', tmplData
    @$el.html @tmpl tmplData
    @$('[data-toggle="popover"]').popover()
    @


class exports.RequestFormInfoView extends BB.ModelSaveView
  # logging: on
  el: '#reqInfo'
  tmpl: require './templates/RequestFormInfo'
  initialize: ->
    @$el.html @tmpl @model.toJSON()
    @$('#status').on 'change', =>
      @$('#canceled-control-group').toggle @$('#status').val() == 'canceled'
      @$('#incomplete-control-group').toggle @$('#status').val() == 'incomplete'
    @companyInfo = new exports.RequestFormInfoCompanyView model: @model
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @listenTo @model, 'change', @render
  render: ->
    @setValsFromModel ['brief','availability','status','canceledReason','incompleteDetail','budget','pricing']
    @companyInfo.render()
    @


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
        s.set 'hasLinks', s.hasLinks()
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
    $log 'expert', expertId, expert
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
    @$el.html ''
    suggested = @model.get 'suggested'
    if !suggested? then return
    else if suggested.length == 0
      @$el.append '<p>No suggestion made...</p>'
    else
      for s in @model.get 'suggested'

        mailData =
          _id: @model.get('_id')
          expertName: s.expert.name
          companyName: @model.get('company').name

        s.body = @mailTmpl mailData
        s.tags =  @model.get 'tags'
        s.expert.hasLinks = new M.Expert(s.expert).hasLinks()

        @$el.append @tmpl s
    @
  remove: (e) ->
    suggestionId = $(e.currentTarget).data 'id'
    toRemove = _.find @model.get('suggested'), (d) -> d._id == suggestionId
    $log 'suggestRemove', suggestionId, toRemove
    @model.set 'suggested', _.without( @model.get('suggested'), toRemove )
    @parentView.save e


# class exports.RequestFormCallsView extends BB.BadassView
#   initialize: ->
#     @listenTo @model, 'change', @render
#   render: ->


class exports.RequestFormView extends BB.ModelSaveView
  logging: on
  async: off
  el: '#requestForm'
  tmpl: require './templates/RequestForm'
  viewData: ['status','brief','canceledReason']
  events:
    'click .save': 'save'
    'click .deleteRequest': 'deleteRequest'
  initialize: ->
    @$el.html @tmpl {}
    @infoView = new exports.RequestFormInfoView model: @model, tags: @tags, parentView: @
    @suggestionsView = new exports.RequestSuggestionsView model: @model, collection: @experts, parentView: @
    @suggestedView = new exports.RequestSuggestedView model: @model, collection: @experts, parentView: @
    # @callsView = new exports.RequestFormCallsView model: @model, parentView: @
    @listenTo @model, 'change', @render
  render: ->
    @$('.btn-review').attr 'href', "/review##{@model.get('_id')}"
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.fetch()
  # getViewData: ->
  #   d = @getValsFromInputs @viewData
  #   d
  deleteRequest: ->
    @model.destroy()
    @collection.fetch()
    router.navigate '#', { trigger: true }
    false

Handlebars.registerPartial "RequestSet", require('./templates/RequestSet')

module.exports = exports