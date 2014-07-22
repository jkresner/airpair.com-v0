exports = {}
BB      = require 'BB'
M       = require './Models'
SV      = require '../../shared/Views'


#############################################################################
## Book
#############################################################################

# class exports.StripeRegisterView extends SV.StripeRegisterView
#   logging: on
#   email: ->
#     @session.get('google')._json.email
#   # meta: ->
#   #   "Enter the card you want to use to pay #{@expert.get('name')}."
#   render: ->
#     super()
#     $('#card').show()
#   stripeCustomerSuccess: (model, resp, opts) =>
#     @model.unset 'stripeCreate'
#     name = @session.get('google').displayName
#     addjs.trackEvent 'book', 'customerSetStripeInfo', name
#     addjs.trackSession paymentInfoSet: 'stripe'
#     @successAction()
#   successAction: =>
#     $('#card').hide()
#     @$el.remove()


# class exports.ThankYouView extends BB.ModelSaveView
#   el: '#thankyou'
#   tmpl: require './templates/ThankYou'
#   initialize: (args) ->
#     @listenTo @model, 'change', @render
#   render: ->
#     @$el.html @tmpl { requestId: @model.id }


class exports.OrderView extends BB.ModelSaveView
  logging: on
  el: '#order'
  # tmpl: require './templates/BookSummary'
  events:
    'click .promocode': 'renderPromo'
    'click .pay': 'pay'
  initialize: (args) ->
    @listenTo @model, 'change', @render
  render: ->
    # @model.setTotal()
    $log 'o.render', @$('.total'), @model.get('total')
    @$('.total').html @model.get('total')
    # @$('#summary').html @tmpl @model.toJSON()
    @
  renderPromo: ->
    code = @elm('promocode').val()
    $.post '/api/landing/airconf/promo',{code}, (data) =>
      $log 'hellooooo????'
      @$('.promocodeMessage').html data.message
      $log 'data', data.promoRate, @model.get('total')
      if data.promoRate != @model.get('total')
        $log 'setting', data.promoRate
        @model.set 'total', data.promoRate
  pay: (e) ->
    # if @model.get('total') is 0
    #   e.preventDefault()
    #   alert('please select at least one hour')
    # else
    #     @model.set('utm', utm_values)

    #   eventName = 'customerTryPayStripe'
    #   # Disable submitBtn to prevent repeat clicks
    #   @$('.payStripe').html('Payment processing ...').prop 'disabled', true

    #   addjs.trackEvent "request", eventName, "/review/book/#{@model.get('requestId')}"

    #   @save(e)
    # false
  getViewData: ->
    @model.attributes
  renderSuccess: (model, resp, opts) =>
    if @isStripeMode
      router.navTo "#thankyou/#{router.app.request.id}"
    else
      @$('#paykey').val model.attributes.payment.payKey
      @$('#submitBtn').click()



# class exports.BookExpertView extends BB.BadassView
#   className: 'bookableExpert'
#   tmpl: require './templates/BookExpert'
#   events:
#     'change select': 'update'
#   initialize: (args) ->
#   render: ->
#     @li = @model.lineItem @suggestion._id
#     @$el.html @tmpl @li
#     @elm('type').val @li.type
#     @elm('qty').val @li.qty
#     @
#   update: ->
#     @li.type = @elm('type').val()
#     @li.qty = parseInt( @elm('qty').val() )
#     @li.unitPrice = @suggestion.suggestedRate[@li.type].total
#     @li.total = @li.qty * @li.unitPrice
#     @model.trigger 'change'
#     @render()


# class exports.BookView extends BB.BadassView
#   el: '#book'
#   tmpl: require './templates/BookInfo'
#   initialize: (args) ->
#     @$el.html @tmpl useSandbox: !@isProd
#     window.PAYPAL = require '/scripts/providers/paypal'
#     @embeddedPPFlow = new PAYPAL.apps.DGFlow trigger: 'submitBtn',type:'light'
#     @orderView = new exports.OrderView model: @model
#     @listenTo @request, 'change', @render
#     @listenTo @model, 'change', =>
#       @$('#selecthours').toggle @mget('total') is 0
#   render: ->
#     if @request.get('suggested')?
#       @model.setFromRequest @request
#       $ul = @$('ul').html('')
#       for li in @model.get('lineItems')
#         $ul.append new exports.BookExpertView(suggestion:li.suggestion,model:@model).render().el
#     @



module.exports = exports
