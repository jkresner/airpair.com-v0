
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

    for set in @$('.requestSet') #show only ones with results
      $(set).toggle $(set).find('td').length > 0
    @


#############################################################################
##  To farm request (share out to different social channels)
#############################################################################


class exports.RequestFarmView extends BB.ModelSaveView
  el: '#farm'
  tmpl: require './templates/RequestFarm'
  tmplLinkedIn: require './templates/RequestFarmLinkedIn'
  tmplTwitter: require './templates/RequestFarmTwitter'
  bitlyUrl: "https://api-ssl.bitly.com/v3"
  accessToken: "b93731e13c8660c7700aca6c3934660ea16fbd5f"
  events:
    'click .shorten': 'shorten'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    if !@mget('base')? then return @
    @rate = @mget('budget') - @mget('base')[@mget('pricing')]
    month = new moment().format("MMM").toLowerCase()
    term = encodeURIComponent @model.tagsString()
    tmplData =
      url: "http://www.airpair.com/review/#{@model.id}?utm_medium=farm-link&utm_campaign=farm-#{month}&utm_term=#{term}"
      urlEncoded: "http://www.airpair.com/review/#{@model.id}%3Futm_medium=farm-link%26utm_campaign=farm-#{month}"
      tagsString: @model.tagsString()
      hrRate: @rate
      bitly: 'https://bitly.com/shorten/?url='
    @$el.html @tmpl @model.extendJSON tmplData
    # @shorten target: @$('#linkedInShorten')
    @
  shorten: (e) ->
    $input = $(e.target).next()
    encodedLnk = encodeURIComponent $input.val()
    $.ajax(url:"#{@bitlyUrl}/shorten?access_token=#{@accessToken}&longUrl=#{encodedLnk}").done (r) =>
      $input.val "http://airpa.ir/#{r.data.hash}"
      tmplData = link: $input.val(), tagsString: @model.tagsString(), hrRate: @rate
      if $input.attr('id') is 'farm-linkedin-group'
        @$('#linkedInJobPostMessage').html @tmplLinkedIn tmplData
      if $input.attr('id') is 'farm-tweet-airpair'
        window.open @tmplTwitter(tmplData)
    false


#############################################################################
##  To edit request
#############################################################################

class CustomerMailTemplates
  tmplReceived: require './../../mail/customerRequestReceived'
  tmplReview: require './../../mail/customerRequestReview'
  tmplMatched: require './../../mail/customerRequestMatched'
  tmplFollowup: require './../../mail/customerRequestFollowup'
  constructor: (request, session) ->
    isOpensource = request.get('pricing') == 'opensource'
    firstName = request.contact(0).fullName.split(' ')[0]
    request.contact(0).firstName = firstName
    r = request.extendJSON tagsString: request.tagsString(), isOpensource: isOpensource, session: session.toJSON()
    @received = encodeURIComponent(@tmplReceived r)
    @review = encodeURIComponent(@tmplReview r)
    @matched = encodeURIComponent(@tmplMatched r)
    @followup = encodeURIComponent(@tmplFollowup r)


class ExpertMailTemplates
  tmplAnother: require './../../mail/expertRequestAnother'
  tmplCancelled: require './../../mail/expertRequestCancelled'
  tmplChosen: require './../../mail/expertRequestChosen'
  tmplSuggested: require './../../mail/expertRequestSuggested'
  constructor: (request, session, expertId) ->
    suggestion = request.suggestion expertId
    suggestion.expert.firstName = suggestion.expert.name.split(' ')[0]
    contact = request.contact 0
    try
      suggestedExpertRate = suggestion.suggestedRate[request.get('pricing')].expert
    # $log 'suggestion', suggestion, contact, request
    r = request.extendJSON { tagsString: request.tagsString(), suggestion: suggestion, contact: contact, suggestedExpertRate: suggestedExpertRate, session: session.toJSON() }
    @another = encodeURIComponent(@tmplAnother r)
    @canceled = encodeURIComponent(@tmplCancelled r)
    @chosen = encodeURIComponent(@tmplChosen r)
    @suggested = encodeURIComponent(@tmplSuggested r)


class exports.RequestInfoView extends BB.ModelSaveView
  el: '#info'
  tmpl: require './templates/RequestInfo'
  tmplCompany: require './templates/RequestInfoCompany'
  events:
    'click #receivedBtn': 'updateStatusToHolding'
  initialize: ->
    @$el.html @tmpl @model.toJSON()
    @$('#status').on 'change', @toggleCanceledIncompleteFields
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @listenTo @model, 'change', @render
  render: ->
    @setValsFromModel ['brief','availability','status','owner','canceledReason','incompleteDetail','budget','pricing']
    mailTemplates = new CustomerMailTemplates @model, @session
    tmplCompanyData = _.extend { mailTemplates: mailTemplates, tagsString: @model.tagsString() }, @mget('company')
    @$('#company-controls').html @tmplCompany(tmplCompanyData)
    @$('[data-toggle="popover"]').popover()
    @$('.status').addClass "label-#{@model.get('status')}"
    @$('.status').html @model.get('status')
    @toggleCanceledIncompleteFields()
    @
  toggleCanceledIncompleteFields: =>
    @$('#canceled-control-group').toggle @$('#status').val() == 'canceled'
    @$('#incomplete-control-group').toggle @$('#status').val() == 'incomplete'
  updateStatusToHolding: ->
    if @mget('status') is 'received'
      @model.set status: 'holding'
      @parentView.save null


class exports.RequestSuggestionsView extends BB.BadassView
  # logging: on
  el: '#suggestions'
  tmpl: require './templates/RequestSuggestions'
  tmplSuggestion: require './templates/RequestSuggestion'
  events:
    'input .autocomplete': 'renderSearchSuggestions'
    'click .add-suggestion': 'add'
    'click .js-tag': 'filterTag'
  initialize: ->
    @listenTo @model, 'change:tags', @render
    @listenTo @model, 'change:suggested', @renderTagSuggestions
  render: ->
    @rTag = null
    if @model.get('tags')? && @model.get('tags').length
      @rTag = @model.get('tags')[0]
    @$el.html @tmpl @model.toJSON()
    @renderTagSuggestions()
    @
  filterTag: (e) ->
    short = $(e.currentTarget).closest('li').data 'short'
    #$log 'filterTag', short
    @rTag = _.find @model.get('tags'), (t) -> t.short == short
    @renderTagSuggestions()
  renderTagSuggestions: ->
    #$log 'renderTagSuggestions', @rTag
    @$('.ops').html ''
    @$('.custom').toggle !@rTag?
    @$('li').removeClass 'active'
    if !@rTag?
      @$("[data-short='custom']").addClass 'active'
    else if @rTag?
      @$("[data-short='#{@rTag.short}']").addClass 'active'
      suggested = _.pluck @model.get('suggested'), 'expert'
      @collection.filterFilteredModels( tag: @rTag, excludes: suggested )
      @renderSuggestions @collection.filteredModels
    false
  renderSearchSuggestions: ->
    @$('.ops').html ''
    search = @$('.autocomplete').val()
    #$log 'renderSearch', @$('.autocomplete').val()
    if search.length > 2
      @collection.filterFilteredModels( searchTerm: search )
      @renderSuggestions @collection.filteredModels
    else
      @renderSuggestions []
  renderSuggestions: (experts) ->
    # $log 'renderSuggestions', experts.length
    for s in experts
      @$('.ops').append @tmplSuggestion(s.toJSON())
    false
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

        s.tags =  @mget 'tags'
        s.expert.hasLinks = new M.Expert(s.expert).hasLinks()

        mailTemplates = new ExpertMailTemplates @model, @session, s.expert._id
        try
          rates = s.suggestedRate[@model.get('pricing')]
        tmplData = _.extend { requestId: @model.id, mailTemplates: mailTemplates, tagsString: @model.tagsString(), rates: rates }, s
        @$el.append @tmpl tmplData
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
  async: off
  el: '#request'
  tmpl: require './templates/Request'
  viewData: ['owner','budget','pricing','status','availability','brief','canceledDetail','incompleteDetail']
  events:
    'click .save': 'save'
    'click .deleteRequest': 'deleteRequest'
  initialize: ->
    @$el.html @tmpl()
    @navView = new exports.RequestNavView el: '#requestNav', model: @model
    @eventsView = new exports.RequestEventsView el: '#events', model: @model
    @infoView = new exports.RequestInfoView model: @model, tags: @tags, session: @session, parentView: @
    @suggestionsView = new exports.RequestSuggestionsView model: @model, collection: @experts, parentView: @
    @suggestedView = new exports.RequestSuggestedView model: @model, collection: @experts, session: @session, parentView: @
    @callsView = new exports.RequestCallsView el: '#calls', model: @model, parentView: @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    m = @collection.findWhere(_id: model.id)
    m.set model.attributes
    @collection.trigger 'sync'  # for the requests view to re-render
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.tags = @infoView.tagsInput.getViewData()
    delete @mget('company').mailTemplates # temp fix for old leak code
    d
  deleteRequest: ->
    @model.destroy wait: true, success: =>
      @collection.fetch success: => router.navTo 'list'
    false

Handlebars.registerPartial "RequestSet", require('./templates/RequestsSet')
Handlebars.registerPartial "MailSignature", require('./../../mail/signature')

module.exports = exports
