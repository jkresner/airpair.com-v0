exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

Handlebars.registerPartial "Expert", require './../shared/templates/Expert'
Handlebars.registerPartial "ExpertMini", require './../shared/templates/ExpertMini'
Handlebars.registerPartial "Suggestion", require './templates/Suggestion'

#############################################################################
## Shared across Expert Review + Experts View
#############################################################################

isCustomer = ->
  return false if !router.app.session.id?
  return true if /iscust/.test(location.href)
  router.app.request.get('userId') == router.app.session.id


class exports.SuggestionView extends BB.BadassView
  tmpl: require './templates/Suggestion'
  initialize: (args) ->
    @reviewForm = new exports.CustomerReviewFormView args
    @model.set requestId: @request.id
  render: ->
    cust = @request.contact(0)
    d = @model.extend custPic: cust.pic, custName: cust.fullName, isCustomer: false
    @$el.html @tmpl d
    if @isCustomer
      @$('.customerReviewForm').append @reviewForm.render().el
      @$('.customerReviewForm').toggle !@mget('customerFeedback')?
      @$('.feedback').toggle @mget('customerFeedback')?
    @


#############################################################################
##
#############################################################################


class exports.ExpertReviewFormView extends BB.EnhancedFormView
  el: '#expertReviewForm'
  tmpl: require './templates/ExpertReviewForm'
  viewData: ['expertRating', 'expertFeedback', 'expertStatus', 'expertComment', 'expertAvailability']
  events:
    'click .saveFeedback': 'save'
  initialize: (args) ->
  render: ->
    @$el.html @tmpl @model.toJSON()
    @elm('expertStatus').on 'change', @toggleFormElements
    @enableCharCount 'expertFeedback'
    @setValsFromModel ['expertRating', 'expertStatus']
    @elm('expertStatus').trigger 'change'
    @
  toggleFormElements: =>
    @renderInputsValid()
    expertStatus = @elm('expertStatus').val()
    @$('.hideShowSave').toggle expertStatus != ''
    if expertStatus is 'available'
      @elm('expertComment').attr 'placeholder', "Comment to the customer on why they should book you for this airpair."
      if @elm('expertAvailability').val() is 'unavailable' then @elm('expertAvailability').val('')
    else if expertStatus is 'abstained'
      @elm('expertComment').attr 'placeholder', "Comment to the customer on why you don't want this airpair. E.g. Are you busy this week?"
      @elm('expertAvailability').val('unavailable').hide()
  renderSuccess: (model, resp, options) =>
    @request.set model.attributes


class exports.ExpertReviewDetailView extends BB.BadassView
  el: '#expertReviewDetail'
  tmpl: require './templates/ExpertReviewDetail'
  render: ->
    @$el.html @tmpl @model.toJSON()
    @


class exports.ExpertReviewView extends BB.BadassView
  el: '#expertReview'
  tmpl: require './templates/ExpertReview'
  events:
    'click .edit': -> @render(true); false
  initialize: (args) ->
    @$el.html @tmpl()
    @reviewFormView = new exports.ExpertReviewFormView args
    @detailView = new exports.ExpertReviewDetailView args
  render: (editing) ->
    @editing = @model.get('expertFeedback') is undefined
    @editing = editing if editing?
    @reviewFormView.render() if @editing
    @reviewFormView.$el.toggle @editing
    @detailView.render() if !@editing
    @detailView.$el.toggle !@editing
    @


#############################################################################
##
#############################################################################


class exports.CustomerReviewFormView extends BB.ModelSaveView
  tmpl: require './templates/CustomerReviewForm'
  events: { 'click .saveFeedback': 'save' }
  initialize: (args) ->
  render: ->
    @$el.html @tmpl @model.toJSON()
    @elm('customerRating').on 'change', @toggleUnwatedCheckbox
    @
  toggleUnwatedCheckbox: =>
    rating = parseInt @elm('customerRating').val()
    @$('.unwanted').toggle rating < 3
  getViewData: (e) ->
    d = @getValsFromInputs ['customerRating', 'customerFeedback']
    if @elm('unwanted').is(':checked') then d.expertStatus = 'unwanted'
    d
  renderSuccess: (model, resp, options) =>
    @request.set model.attributes


class exports.CustomerReviewView extends BB.BadassView
  el: '#customerReview'
  tmpl: require './templates/Experts'
  initialize: (args) ->
  render: ->
    @$el.html @tmpl @request.toJSON()
    for s in @request.get('suggested')
      args = model: new M.CustomerReview(s), request: @request, session: @session
      @$('.ul').append new exports.SuggestionView(args).render().el
    @


#############################################################################
##
#############################################################################


class exports.NotExpertOrCustomerView extends BB.BadassView
  el: '#notExpertOrCustomer'
  tmpl: require './templates/NotExpertOrCustomer'
  render: ->
    @$el.html @tmpl @request.extend authenticated: @session.authenticated(), tagsString: @request.tagsString()
    @


#############################################################################
##
#############################################################################


class exports.RequestInfoView extends BB.BadassView
  el: '#info'
  tmpl: require './templates/Info'
  render: ->
    @$el.html @tmpl @model.extend isCustomer: isCustomer(), total: @hrTotal()
    @
  hrTotal: -> #TODO remove from view and put into model
    t = @mget('budget')
    pricing = @mget('pricing')
    if pricing is 'private' then t = t+20
    if pricing is 'nda' then t = t+60
    t


class exports.RequestView extends BB.BadassView
  el: '#request'
  tmpl: require './templates/Request'
  initialize: (args) ->
    @$el.html @tmpl()
    @infoView = new exports.RequestInfoView model: @request
    @anonView = new exports.NotExpertOrCustomerView args
    @customerReviewView = new exports.CustomerReviewView args
    expArgs = _.extend args, { model: new M.ExpertReview() }
    @expertReviewView = new exports.ExpertReviewView expArgs
    @request.on 'change', @render, @
  render: ->
    @infoView.render()
    meExpert = @request.suggestion @session.id
    $log 'rendered', meExpert, @request.attributes.suggested
    if meExpert?
      @expertReviewView.model.set _.extend(meExpert, { requestId: @request.id })
      @expertReviewView.render()
    else if isCustomer()
      @customerReviewView.render()
    else
      @anonView.render()
    @



module.exports = exports