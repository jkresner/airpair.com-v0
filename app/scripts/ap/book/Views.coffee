exports = {}
BB      = require 'BB'
M       = require './Models'
SV      = require '../../shared/Views'
RV      = require '../../ap/request/Views'

#############################################################################
##
#############################################################################


class exports.WelcomeView extends BB.BadassView
  el: '#welcome'
  tmpl: require './templates/Welcome'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    localUrl = window.location.pathname+window.location.search
    @$el.html @tmpl @model.extend { localUrl }


class exports.StripeRegisterView extends SV.StripeRegisterView
  email: ->
    @session.get('google')._json.email
  # meta: ->
  #   "Enter the card you want to use to pay #{@expert.get('name')}."
  render: ->
    super()
    $('#card').show()
  stripeCustomerSuccess: (model, resp, opts) =>
    @model.unset 'stripeCreate'
    name = @session.get('google').displayName
    addjs.trackEvent 'book', 'customerSetStripeInfo', name
    addjs.trackSession paymentInfoSet: 'stripe'
    @successAction()
  successAction: =>
    $('#card').hide()
    @$el.remove()

class exports.RequestView extends BB.ModelSaveView
  el: '#request'
  tmpl: require './templates/Request'
  events: { 'click .save': 'save' }
  initialize: ->
    @listenTo @settings, 'change', @render
  render: ->
    if @settings.paymentMethod('stripe')?
      @e = addjs.events.customerRequest
      fName = @expert.get('name').split(' ')[0]
      @$el.html @tmpl @model.extend { expert: @expert.toJSON(), expertFirstName: fName }
      @elm('hours').on 'change', @update
      @elm('pricing').on 'click', @update
      @$('.pricing input:radio').on 'click', @showPricingExplanation
      @$(":radio[value=#{@model.get('pricing')}]").click().prop('checked',true)
      @$(".pricingOpensource span").html @model.private
      @$(".pricingNDA span").html @model.nda-@model.private

      @$(".save").mouseover(=>
        hrs = parseInt @elm('hours').val()
        @$('.save').html "You will be charged $#{@getBudget()*hrs} if #{fName} accepts"
      ).mouseout(=>
        @update()
      )
  update: (e) =>
    hrs = parseInt @elm('hours').val()
    pricing = @$("[name='pricing']:checked").val()
    budget = parseInt(@expert.get('bookMe').rate) + @model[pricing]
    total = hrs * budget
    if hrs == 1
      @$('.save').html "Request #{hrs} hour for $#{total} <span>( #{pricing} )</span>"
    else
      @$('.save').html "Request #{hrs} hours for $#{total} <span>( $#{budget}/#{pricing} hr )</span>"
  selectRB: (e) =>
    rb = $(e.currentTarget)
    group = rb.parent()
    group.find("label").removeClass 'checked'
    rb.prev().addClass 'checked'
  showPricingExplanation: =>
    @$('.pricing-group em').removeClass 'selected'
    val = @$("[name='pricing']:checked").val()
    @$("em.#{val}").addClass 'selected'
  getViewData: ->
    company: @company.toJSON()
    budget: @getBudget()
    brief: @elm("brief").val()
    hours: @elm("hours").val()
    availability: @elm("availability").val()
    pricing: @$("[name='pricing']:checked").val()
    suggested: [{expert:@expert.toJSON(),suggestedRate:@getBudget()}]
  renderSuccess: (model, response, options) =>
    addjs.trackEvent 'book', @e.name, @model.contact(0).fullName
    if @company.get('name')?
      router.navTo 'thanks'
    else
      $('.detail').hide()
      $('#info').show()
      router.app.expertView.renderHalf()
  getBudget: ->
    parseInt(@expert.get('bookMe').rate) + @model[@$("[name='pricing']:checked").val()]


class exports.InfoFormView extends RV.InfoFormView
  tmplWrap: require './templates/InfoForm'
  renderSuccess: (model, response, options) =>
    if @isReturnCustomer
      @e.name = "customerInfoRepeat"
    addjs.trackEvent @e.category, @e.name, @elm('fullName').val(), @timer.timeSpent()
    addjs.trackSession isCustomer : 'Y'
    router.navTo 'thanks'
    @request.urlRoot = '/api/requests'
    @request.save 'company', model.attributes
    $('#info').hide()


class exports.ExpertView extends BB.BadassView
  el: '#expert'
  tmpl: require './templates/Expert'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    rate = parseInt(@model.get('bookMe').rate) + @request.private
    @$el.html @tmpl @model.extend { publicRate: rate, authenticated: @session.id? }
  renderHalf: ->
    $('.booking-stats').hide()



# class exports.SigninView extends BB.BadassView
#   el: '#signin'
#   events: { 'click .track': 'track' }
#   initialize: ->
#     @e = addjs.events.customerLogin
#     @e2 = addjs.events.customerBookExpert
#   render: ->
#     @$el.html @tmpl()
#     trackWelcome = => addjs.trackEvent @e2.category, @e2.name, @e2.uri, 0
#     setTimeout trackWelcome, 400
#   track: (e) =>
#     e.preventDefault()
#     # addjs.trackEvent @e.category, @e.name, @e.uri, @timer.timeSpent()
#     setTimeout @oauthRedirect, 400
#     false
#   oauthRedirect: ->
#     window.location =
#       "/auth/google?return_to=#{window.location.pathname}&mixpanelId=#{mixpanel.get_distinct_id()}"


module.exports = exports
