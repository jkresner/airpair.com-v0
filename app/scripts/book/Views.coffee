exports = {}
BB      = require './../../lib/BB'
M       = require './Models'
SV      = require './../shared/Views'


#############################################################################
##
#############################################################################


class exports.StripeRegisterView extends SV.StripeRegisterView
  email: ->
    @session.get('google')._json.email
  meta: ->
    "Enter the card you want to use to pay #{@expert.get('name')}."
  stripeCustomerSuccess: (model, resp, opts) =>
    @model.unset 'stripeCreate'
    addjs.providers.mp.setPeopleProps paymentInfoSet: 'stripe'
    @successAction()
  successAction: =>
    @$el.remove()


class exports.WelcomeView extends BB.BadassView
  logging: on
  el: '#welcome'
  tmpl: require './templates/Welcome'
  initialize: ->
    @$el.html @tmpl { localUrl: window.location.pathname }
    @listenTo @model, 'change', @render
  render: ->
    @$('#bookme-login').html "Login to book hours with #{@model.get('name')}"


class exports.RequestView extends BB.ModelSaveView
  el: '#request'
  tmpl: require './templates/Request'
  events: { 'click .save': 'save' }
  initialize: ->
    @listenTo @settings, 'change', @render
  render: ->
    if @settings.paymentMethod('stripe')?
      # @e = addjs.events.bookRequest
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
        @$('.save').html "We'll charge your card $#{@getBudget()*hrs} if #{fName} accepts"
      ).mouseout(=>
        @update()
      )

      # <p></p>

      # $log '@elm', @elm('hours')
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
    addjs.providers.mp.incrementPeopleProp "requestCount"
    # addjs.trackEvent @e.category, @e.name, @model.contact(0).fullName, @timer.timeSpent()
    router.navTo 'thanks'
  getBudget: ->
    parseInt(@expert.get('bookMe').rate) + @model[@$("[name='pricing']:checked").val()]


class exports.ExpertView extends BB.BadassView
  # logging: on
  el: '#expert'
  tmpl: require './templates/Expert'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    rate = parseInt(@model.get('bookMe').rate) + @request.private
    @$el.html @tmpl @model.extend { publicRate: rate }



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
