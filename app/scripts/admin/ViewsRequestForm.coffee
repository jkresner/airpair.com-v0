exports = {}
BB = require './../../lib/BB'
M = require './Models'


class exports.RequestFormInfoView extends BB.BadassView
  el: '#reqInfo'
  tmpl: require './templates/RequestFormInfo'
  events:
    'click .deleteAvalability': 'deleteAvalability'
  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @collection, 'sync', @render
  render: ->
    if @collection.length is 0 then return
    tmplData = _.extend @model.toJSON(), { companys: @collection.toJSON(), skillsSoIds: @model.skillSoIdsList() }
    @$el.html @tmpl tmplData
    #$log 'RequestFormInfoView.render', arguments, tmplData
    @$('#reqCompany').val @model.get 'companyId'
    @$('#reqStatus').val @model.get 'status'
    @$('#reqAvailability').datetimepicker( minuteStep: 30, autoclose: true )
    @$('#reqAvailability').on 'dateChanged', @addAvailability
    @$('#reqStatus').on 'change', =>
      @$('#canceled-control-group').toggle @$('#reqStatus').val() == 'canceled'
    @
  addAvailability: (e) =>
    # this one is comes back from the datetimepicker event handler
    # todo, check for duplicates
    @model.get('availability').push e.date
    @parentView.save e   #some funky shit going on with skills, this just works because of getViewData
  deleteAvalability: (e) ->
    toRemove = $(e.currentTarget).data 'val'
    @model.set 'availability', _.without( @model.get('availability'), toRemove )
    @parentView.save e


class exports.RequestFormSuggestionsView extends BB.BadassView
  #logging: on
  el: '#reqSuggestions'
  tmpl: require './templates/RequestFormSuggestions'
  mailTmpl: require './../../mail/developerMatched'
  events:
    'click .suggestDev': 'add'
    'click .deleteSuggested': 'remove'
    'click a.mailMatched': 'sendMatchedMail'
  initialize: ->
    @listenTo @collection, 'sync', @render
    @listenTo @model, 'change', @render
  render: ->
    tmplData = _.extend @model.toJSON(), { devs: @collection.toJSON() }
    #$log 'render suggestions', @, @$el, @tmpl, tmplData
    @$el.html @tmpl tmplData
    @
  add: (e) ->
    if @$('#reqDev').val() == '' then alert 'select a dev'; return false
    # todo, check for duplicates
    @model.get('suggested').push
      status: 'awaiting'
      events: [{ 'created': new Date() }]
      dev: { _id: @$('#reqDev').val(), name: @$('#reqDev option:selected').text() }
      availability: []
      comment: ''
    @parentView.save e
  remove: (e) ->
    suggestionId = $(e.currentTarget).data 'id'
    toRemove = _.find @model.get('suggested'), (d) -> d._id = suggestionId
    $log 'suggestRemove', suggestionId, toRemove
    @model.set 'suggested', _.without( @model.get('suggested'), toRemove )
    @parentView.save e
  sendMatchedMail: (e) ->
    e.preventDefault()
    devId = $(e.currentTarget).data 'id'
    skillList = @model.skillSoIdsList()
    developers = _.pluck @model.get('suggested'), 'dev'
    dev = _.find developers, (d) -> d._id == devId
    companyId = @model.get 'companyId',
    $log 'companyId', companyId, @companys.models, @model
    company = @companys.findWhere _id: companyId
    #$log 'company', company
    mailtoAddress = "#{dev.name}%20%3c#{dev.email}%3e"
    body = @mailTmpl dev_name: dev.name, entrepreneur_name: company.get('contacts')[0].fullName, leadId: @model.get('_id')
    window.open "mailto:#{mailtoAddress}?subject=airpair - Help an entrepreneur with #{skillList}?&body=#{body}"


class exports.RequestFormCallsView extends BB.BadassView
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->


class exports.RequestFormView extends BB.ModelSaveView
  #logging: on
  async: off
  el: '#requestForm'
  tmpl: require './templates/RequestForm'
  viewData: ['companyId','status','skills','brief','canceledReason']
  mailTmpl: require './../../mail/developersContacted'
  events:
    'click #mailDevsContacted': 'sendDevsContacted'
    'click .save': 'save'
    'click .delete': 'deleteRequest'
  initialize: ->
    @$el.html @tmpl()
    @infoView = new exports.RequestFormInfoView model: @model, collection: @companys, parentView: @
    @suggestionsView = new exports.RequestFormSuggestionsView model: @model, collection: @devs, companys: @companys, parentView: @
    @callsView = new exports.RequestFormCallsView model: @model, parentView: @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    # @model.set model.attributes
    @collection.fetch()
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.companyName = @$('#reqCompany option:selected').text()
    d
  sendDevsContacted: (e) ->
    e.preventDefault()
    cid = @model.get 'companyId'
    company = _.find @companys.models, (m) -> m.get('_id') == cid
    customer = company.get('contacts')[0]
    # $log 'sendDevsContacted', customer, cid
    mailtoAddress = "#{customer.fullName}%20%3c#{customer.email}%3e"
    body = @mailTmpl2 entrepreneur_name: customer.name, leadId: @model.id
    window.open "mailto:#{mailtoAddress}?subject=airpair - We've got you some devs!&body=#{body}"
  deleteRequest: ->
    model.destroy()
    @collection.fetch()
    router.naviate '#', false
    false


module.exports = exports