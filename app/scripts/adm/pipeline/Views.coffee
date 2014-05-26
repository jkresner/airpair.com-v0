exports          = {}
BB               = require 'BB'
M                = require './Models'
SV               = require '../../shared/Views'
OV               = require './../orders/Views'
storage          = require('../../shared/util').storage
calcExpertCredit = require 'lib/mix/calcExpertCredit'

#############################################################################
##  To render requests rows for admin
#############################################################################

class exports.FiltersView extends BB.BadassView
  el: '#filters'
  events:
    'click .btn': 'filterRequests'
  initialize: ->
    # both initial page load and hitting #inactive trigger this
    @listenTo @collection, 'sync', =>
      owner = storage('inbound.owner')
      if !owner then return
      @highlightBtn $(".btn:contains(#{owner})")
      @filterByOwner owner

  filterRequests: (e) ->
    $btn = $(e.currentTarget)
    @highlightBtn $btn
    @filterByOwner $btn.text()

  highlightBtn: ($btn) ->
    # save currently selected button to localstorage
    storage('inbound.owner', $btn.text()) # keep the case
    $btn.siblings('button').removeClass('btn-warning')
    $btn.addClass('btn-warning')

  filterByOwner: (owner) ->
    @collection.filterFilteredModels
      filter: owner
      sort: true


class exports.RequestRowView extends BB.BadassView
  tagName: 'tr'
  className: 'requestRow'
  tmpl: require './templates/Row'
  events:
    'click .edit': 'edit'
  render: ->
    d = @model.toJSON()
    d.company.contacts[0] = {} if !d.company.contacts[0]?

    tmplData = _.extend d, {
      contactName:        d.company.contacts[0].fullName
      contactPic:         d.company.contacts[0].pic
      contactEmail:       d.company.contacts[0].email
      createdDate:        @model.createdDateString()
      createdAgoString:   moment(@model.createdDate()).fromNow()
      createdAgoClass:    @createdAgoHtml()
      suggestedCount:     d.suggested.length
      suggestedFitCount:  _.filter(d.suggested, (s) -> s.status is 'chosen').length
      callCount:          d.calls.length
      callCompleteCount:  _.filter(d.calls, (c) -> c.recordings.length > 0).length
    }
    @$el.html @tmpl tmplData
    @
  edit: (e) ->
    e.preventDefault()
    link = $(e.target)
    route = link.attr('href').substring(1)
    router.app.selected.set('_id', link.data('id'), { silent: true })
    # console.log 'view fetching'
    router.app.selected.fetch
      reset: true,
      success: =>
        router.navTo route
    false
  createdAgoHtml: ->
    status = @model.get('status')
    if status == 'received' || status == 'pending'
      createdDate = @model.createdDate()
      return ' overdue' if moment(createdDate).add('hours',3).isBefore()
      return ' slow' if moment(createdDate).add('hours',1).isBefore()
      ' ok'


class exports.RequestsView extends BB.BadassView
  el: '#requests'
  tmpl: require './templates/Requests'
  initialize: (args) ->
    @listenTo @collection, 'sync filter', @render # filter sort
  render: ->
    @$el.html @tmpl( count: @collection.filteredModels.length )

    for m in @collection.filteredModels
      sts = m.get('status')
      @$("##{sts} tbody").append new exports.RequestRowView( model: m ).render().el

    for set in @$('.requestSet') #show only ones with results
      $(set).toggle $(set).find('td').length > 0
    @


#############################################################################
##  To farm request (share out to different social channels)
#############################################################################


class exports.RequestFarmEmailView extends BB.ModelSaveView
  el: '#farmEmail'
  tmpl: require './templates/RequestFarmEmail'
  tmplResult: require './templates/RequestFarmEmailResult'
  events:
    'change input': 'setModel'
  initialize: ->
    @$el.html @tmpl @request.toJSON()
    @model = new BB.BadassModel() # Note model does not have server state
    @listenTo @model, 'change', @renderEmail
  setModel: (e) ->
    $input = $(e.target)
    @model.set $input.attr('name'), $input.val()
  renderEmail: (e) ->
    fd = @request.getFarmData()
    fd.url = "http://www.airpair.com/review/#{@request.id}?utm_medium=farm-link&utm_campaign=farm-#{fd.month}&utm_term=#{fd.term}"

    @$('#emailResult').html @tmplResult @model.extend(fd)
    @


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
    @fd = @model.getFarmData()
    @fd.url = "http://www.airpair.com/review/#{@model.id}?utm_medium=farm-link&utm_campaign=farm-#{@fd.month}&utm_term=#{@fd.term}"
    @$el.html @tmpl @model.extendJSON @fd
    if @emailTemplateView? then @emailTemplateView.remove()
    @emailTemplateView = new exports.RequestFarmEmailView request: @model
    @
  shorten: (e) ->
    $input = $(e.target).next()
    encodedLnk = encodeURIComponent $input.val()
    $.ajax(url:"#{@bitlyUrl}/shorten?access_token=#{@accessToken}&longUrl=#{encodedLnk}").done (r) =>
      $input.val "http://airpa.ir/#{r.data.hash}"
      tmplData = link: $input.val(), tagsString: @fd.tagsString, hrRate: @fd.hrRate
      if $input.attr('id') is 'farm-linkedin-group'
        @$('#linkedInJobPostMessage').html @tmplLinkedIn tmplData
      if $input.attr('id') is 'farm-tweet-airpair'
        window.open @tmplTwitter(tmplData)
    false


#############################################################################
##  To auto setup a HipChat Room
#############################################################################


class exports.RoomMemberView extends BB.ModelSaveView
  logging: on
  class: 'control-group'
  tmpl: require './templates/RoomMember'
  viewData: ['email','name','mention_name']
  events:
    'click .btn-create': 'createUser'
    'change .email': 'lookupUser'
  initialize: ->
    @listenTo @model, 'sync', @render
    @model.fetch()
  render: ->
    @$el.html @tmpl @model.toJSON()
  renderError: =>
    @render()
  createUser: ->
    @model.url = -> "/api/chat/users"
    @model.save @getViewData()
    false
    # title: 'Matchmaker',
    # is_group_admin: false,
    # timezone: 'UTC',
    # password: '',
  lookupUser: ->
    @model.set 'email', @elm('email').val()
    @model.fetch()


class exports.RoomView extends BB.ModelSaveView
  # logging: on
  el: '#room'
  tmpl: require './templates/Room'
  events: ->
    'click .btn-create': 'save'
    'click .toggle': 'toggleAssociation'
    'click .send-msg': 'sendMsg'
  initialize: ->
    @listenTo @collection, 'sync', @render
    @listenTo @members, 'change', @renderCreate
  setFromSuggestion: (suggestionId) ->
    sug = @request.suggestion suggestionId
    if !sug? then return $log "RoomView. uhhh no suggestion for #{suggestionId}"
    @suggestion.silentReset sug
    @collection.companyId = @request.get('company')._id
    @collection.fetch()
  render: ->
    if @request.get('tags').length is 0 then return alert 'need one tech tag'
    @model.silentReset @collection.getForSuggestion @suggestion.id

    customer = @request.contact 0
    expert = @suggestion.get('expert')

    d =
      rId: @request.id
      tagsString: @request.tagsString()
      primaryTag: @request.get('tags')[0].short
      rooms: @collection.toJSON()
      room: @model.toJSON()

    if @model.id
      @$el.html @tmpl _.extend d,
        members: @model.get('members')
        roomJSON: JSON.stringify(_.omit(@model.attributes,'members'), null, 2)

    else
      customer.name = customer.fullName
      @members.reset []
      @members.add _.pick customer, 'email','name'
      @members.add _.pick expert, 'email','name'
      @members.add email: "#{@request.get('owner')}@airpair.com", name: 'adm'

      name = "#{customer.firstName}+#{expert.firstName} {#{d.primaryTag}}"
      @$el.html @tmpl _.extend d, {@members,name,expert,customer}
      for m in @members.models
        @$('#members').append new exports.RoomMemberView(model: m).$el
    @
  renderCreate: ->
    if @members.existingCount() >= 3
      @$('.btn-create').removeClass('disabled').addClass('btn-success')
  toggleAssociation: (e) ->
    room = @model
    roomId = $(e.target).data 'roomid'
    if roomId? then room = @collection.findWhere _id: roomId
    sIds = room.get('suggestionIds')
    if _.contains sIds, @suggestion.id
      sIds = _.without sIds, @suggestion.id
    else
      sIds.push @suggestion.id
    room.save {suggestionIds:sIds}, {success:@render}
    false
  getViewData: ->
    members: @members.toJSON()
    suggestionIds: [@suggestion.id]
    name: @elm('roomName').val()
    owner: @request.get('owner')
    companyId: @request.get('company')._id
  sendMsg: ->
    msg = new Backbone.Model()
    msg.urlRoot = '/api/chat/msg'
    msg.save { msg: @elm('msg').val(), roomId: @model.get('hipChatId'), format: 'text' }, success: -> alert('sent')
    false
  renderSuccess: (model) => @collection.fetch()


#############################################################################
##  To edit request
#############################################################################

class CustomerMailTemplates
  tmplReceived: require 'mail/customerRequestReceived'
  tmplIncomplete: require 'mail/customerRequestIncomplete'
  tmplReview: require 'mail/customerRequestReview'
  tmplFollowup: require 'mail/customerRequestFollowup'
  constructor: (request, session) ->
    isOpensource = request.get('pricing') == 'opensource'
    firstName = request.contact(0).fullName.split(' ')[0]
    request.contact(0).firstName = firstName
    r = request.extendJSON tagsString: request.tagsString(), isOpensource: isOpensource, session: session.toJSON()
    if r.status == 'incomplete'
      @incomplete = encodeURIComponent @tmplIncomplete r
    else if r.status == 'pending'
      # no email templates
    else if r.status == 'received' || r.status == 'holding'
      @received = encodeURIComponent @tmplReceived r
    else if r.status == 'consumed' || r.status == 'completed'
      @followup = encodeURIComponent @tmplFollowup r
    else
      @review = encodeURIComponent @tmplReview r


class ExpertMailTemplates
  tmplAnother: require 'mail/expertRequestAnother'
  tmplCancelled: require 'mail/expertRequestCancelled'
  tmplChosen: require 'mail/expertRequestChosen'
  tmplSuggested: require 'mail/expertRequestSuggested'
  tmplBookMe: require 'mail/expertRequestBookMe'
  constructor: (request, session, expertId) ->
    suggestion = request.suggestion expertId
    suggestion.expert.firstName = suggestion.expert.name.split(' ')[0]
    contact = request.contact 0
    try
      suggestedExpertRate = suggestion.suggestedRate[request.get('pricing')].expert
    # $log 'suggestion', suggestion, contact, request

    r = request.extendJSON { tagsString: request.tagsString(), suggestion: suggestion, contact: contact, suggestedExpertRate: suggestedExpertRate, session: session.toJSON() }

    @canceled = encodeURIComponent @tmplCancelled r
    if r.status is 'pending'
      @bookMe = encodeURIComponent @tmplBookMe r
    else if suggestion.expertStatus is 'waiting'
      @suggested = encodeURIComponent @tmplSuggested r
    else if suggestion.expertStatus is 'available'
      @another = encodeURIComponent @tmplAnother r
      @chosen = encodeURIComponent @tmplChosen r
    # else if suggestion.expertStatus is 'declined'
      # details changes... more money new brief?

class exports.RequestInfoView extends BB.ModelSaveView
  # logging: on
  el: '#info'
  tmpl: require './templates/RequestInfo'
  tmplCompany: require './templates/RequestInfoCompany'
  events:
    'click #receivedBtn': 'updateStatusToHolding'
    'change #status': 'updateStatus'
  modelProps: ['brief', 'availability', 'status', 'owner', 'canceledDetail',
    'incompleteDetail', 'budget', 'pricing']
  initialize: ->
    @$el.html @tmpl @model.toJSON()
    @$('#status').on 'change', @toggleCanceledIncompleteFields
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @listenTo @model, "change:brief change:vailability change:status change:owner change:canceledDetail change:incompleteDetail change:budget change:pricing", @render
    @listenTo @model, 'change:tags change:company change:status', @renderMailTemplates
  render: ->
    @setValsFromModel @modelProps
    @toggleCanceledIncompleteFields()
    @
  renderMailTemplates: ->
    data =
      mailTmpls: new CustomerMailTemplates @model, @session
      tagsString: @model.tagsString()
      threeTagsString: @model.threeTagsString()
    tmplCompanyData = _.extend data, @mget('company')
    @$('#company-controls').html @tmplCompany(tmplCompanyData)
    @$('[data-toggle="popover"]').popover()
  toggleCanceledIncompleteFields: =>
    @$('#canceled-control-group').toggle @$('#status').val() == 'canceled'
    @$('#incomplete-control-group').toggle @$('#status').val() == 'incomplete'
  updateStatusToHolding: ->
    if @mget('status') is 'received'
      @elm('status').val('holding').change()
  updateStatus: (e) ->
    s = @$('#status').val()
    if s != 'incomplete' && s != 'canceled' # don't want to fire validation
      @model.set status: s
      @parentView.save e


class exports.RequestMarketingTagsInfoView extends BB.BadassView
  el: '#marketingTagsInfo'
  tmpl: require './templates/RequestMarketingTagsInfo'
  initialize: ->
    @$el.html @tmpl()
    @marketingTagsInput = new SV.MarketingTagsInputView
      model: @model, collection: @marketingTags

class exports.RequestSuggestionsView extends BB.BadassView
  # logging: on
  el: '#suggestions'
  tmpl: require './templates/RequestSuggestions'
  tmplSuggestion: require './templates/RequestSuggestion'
  events:
    'input .autocomplete': 'renderSearchSuggestions'
    'click .add': 'add'
    'click .js-tag': 'filterTag'
    'click .sortBy input': 'sort'
  initialize: ->
    @listenTo @model, 'change:tags', @render
    @listenTo @model, 'change:suggested', @renderTagSuggestions
  render: ->
    @rTag = null
    @$el.html @tmpl @model.toJSON()
    @renderTagSuggestions()
    @
  filterTag: (e) ->
    short = $(e.currentTarget).closest('li').data 'short'
    #$log 'filterTag', short
    @rTag = _.find @model.get('tags'), (t) -> t.short.toLowerCase() == short.toLowerCase()
    @renderTagSuggestions()
  sort: (e) ->
    @collection.comparator = @collection.comparators[$(e.target).val()]
    @renderTagSuggestions()
    true
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
      @collection.filterFilteredModels tag: @rTag, excludes: suggested, sort: true
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
    false


class exports.RequestSuggestedView extends BB.BadassView
  el: '#suggested'
  tmpl: require './templates/RequestSuggested'
  events:
    'click .suggestDev': 'add'
    'click .deleteSuggested': 'remove'
  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @orders, 'sync', @render
  render: ->
    @$el.html '<legend>Suggested</legend>'
    suggested = @model.sortedSuggestions()
    if !suggested? then return
    else if suggested.length == 0
      @$el.append '<p>No suggestion made...</p>'
    else
      for s in suggested
        s.tags =  @mget 'tags'
        s.expert.hasLinks = new M.Expert(s.expert).hasLinks()
        mailTemplates = new ExpertMailTemplates @model, @session, s.expert._id
        try
          rates = s.suggestedRate[@model.get('pricing')]
        s.credit = calcExpertCredit(@orders.toJSON(), s.expert._id)
        tmplData =
          requestId: @model.id
          contact: @model.get('company').contacts[0]
          mailTemplates: mailTemplates
          tagsString: @model.tagsString()
          threeTagsString: @model.threeTagsString()
          rates: rates
        @$el.append @tmpl _.extend tmplData, s
    @
  remove: (e) ->
    suggestionId = $(e.currentTarget).data 'id'
    toRemove = _.find @model.get('suggested'), (d) -> d._id == suggestionId
    $log 'suggestRemove', suggestionId, toRemove
    @model.set 'suggested', _.without( @model.get('suggested'), toRemove )
    @parentView.save e


class exports.OrderRowView extends OV.OrderRowView
  tmpl: require './templates/OrderRow'

class exports.RequestOrdersView extends BB.BadassView
  el: '#orders'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    @$el.toggle @collection.models.length > 0
    $list = @$('tbody').html ''
    for m in @collection.models
      $list.append new exports.OrderRowView( model: m ).render().el
      for li in m.get 'lineItems'
        if 'pending' == m.get 'paymentStatus' then continue
    @



class exports.RequestCallsView extends BB.BadassView
  tmpl: require './templates/RequestCalls'
  initialize: -> @listenTo @model, 'change', @render
  render: ->
    d = @model.toJSON()
    d.calls = d.calls.sort (a, b) -> a.datetime.localeCompare(b.datetime)
    d.calls = d.calls.map (call) =>
      call.expert = @model.suggestion(call.expertId).expert
      call
    @$el.html @tmpl d


class exports.RequestEventsView extends BB.BadassView
  tmpl: require './templates/RequestEvents'
  initialize: -> @listenTo @model, 'change', @render
  render: ->
    # most recent events at the top of the list
    events = @model.get('events').sort (a, b) ->
        new Date(a.utc).getTime() - new Date(b.utc).getTime()
      .reverse()
    @$el.html @tmpl { events: events }


class exports.RequestNavView extends BB.BadassView
  tmpl: require './templates/RequestNav'
  initialize: -> @listenTo @model, 'change', @render
  render: ->
    d = @collection.prevNext(@model.id)
    @$el.html @tmpl @model.extendJSON d


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
    @navView = new exports.RequestNavView el: '#requestNav', model: @model, collection: @collection
    @eventsView = new exports.RequestEventsView el: '#events', model: @model
    @infoView = new exports.RequestInfoView model: @model, tags: @tags, marketingTags: @marketingTags, session: @session, parentView: @
    @marketingInfoView = new exports.RequestMarketingTagsInfoView model: @model, marketingTags: @marketingTags, parentView: @
    @suggestionsView = new exports.RequestSuggestionsView model: @model, collection: @experts, parentView: @
    @suggestedView = new exports.RequestSuggestedView model: @model, collection: @experts, session: @session, orders: @orders, parentView: @
    @callsView = new exports.RequestCallsView el: '#calls', model: @model, parentView: @
    @ordersView = new exports.RequestOrdersView el: '#orders', collection: @orders, model: new @orders.model()
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    m = @collection.findWhere(_id: model.id)
    m.set model.attributes
    @collection.trigger 'sync'  # for the requests view to re-render
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.tags = @infoView.tagsInput.getViewData()
    d.marketingTags = @marketingInfoView.marketingTagsInput.getViewData()
    delete @mget('company').mailTemplates # temp fix for old leak code
    d
  deleteRequest: ->
    @model.destroy wait: true, success: =>
      @collection.fetch success: => router.navTo ''
    false

Handlebars.registerPartial "RequestSet", require './templates/RequestsSet'
Handlebars.registerPartial "MailSignature", require 'mail/signature'

module.exports = exports
