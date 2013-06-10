exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

Handlebars.registerPartial "Expert", require './../shared/templates/Expert'
Handlebars.registerPartial "ExpertMini", require './../shared/templates/ExpertMini'

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
    $log '@isCustomer', @isCustomer
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
    $log 'renderInputsValid'
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


class exports.ExpertReviewView extends BB.BadassView
  logging: on
  el: '#expertReview'
  tmpl: require './templates/ExpertReview'
  events:
    'click .edit': -> @editing = true; @render(); false
  initialize: (args) ->
    @model.set requestId: @request.id
    @editing = @mget('expertFeedback') is undefined
  render: ->
    @$el.html @tmpl @model.toJSON()
    viewArgs = model: @model, request: @request, session: @session
    if @reviewForm? then @reviewForm.remove()
    @reviewForm = new exports.ExpertReviewFormView(viewArgs).render()
    @reviewForm.$el.toggle @editing
    if @suggestion? then @suggestion.remove()
    @suggestion = new exports.SuggestionView(viewArgs)
    @$('.suggestion').append @suggestion.render().el
    $log 'editing', @editing, @$('.suggestion')
    @$('#expertReviewDetail').toggle !@editing
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
    @request.on 'change', @render, @
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
    @infoView = new exports.RequestInfoView model: @model
    @model.on 'change:tags', @render, @
  render: ->
    if @v? then @v.remove()
    @infoView.render()
    viewArgs = request: @model, session: @session
    suggested = @model.suggestion(@session.id)
    if isCustomer()
      @v = new exports.CustomerReviewView viewArgs
    else if suggested? # is expert suggestion
      viewArgs.model = new M.ExpertReview(suggested)
      @v = new exports.ExpertReviewView viewArgs
    else
      @v = new exports.NotExpertOrCustomerView viewArgs
    @v.render()
    @




module.exports = exports