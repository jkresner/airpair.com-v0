exports = {}
BB = require './../../lib/BB'
M = require './Models'
# SV = require './../shared/Views'

#############################################################################
## Shared across Expert Review + Experts View
#############################################################################

class exports.RegisterView extends BB.BadassView
  logging: on
  el: '#stripe'
  tmpl: require './templates/Register'
  initialize: (args) ->
    @model.once 'sync', @render, @
  render: ->
    @$el.html @tmpl()

    $('[data-stripe=number]').val("4242 4242 4242 4242");
    $('[data-stripe=cvc]').val("424");
    $('[data-stripe=exp-month]').val("10");
    $('[data-stripe=exp-year]').val("14");

    @$form = $(@$el.find('form')[0])

    @$form.on 'submit', (e) => 
      e.preventDefault()
      # Disable the submit button to prevent repeated clicks
      @$form.find('button').prop 'disabled', true
      Stripe.card.createToken @$form, @stripeResponseHandler
      false

    @
  stripeResponseHandler: (status, response) =>
    if response.error
      # Show the errors on the form
      @$form.find('.payment-errors').text response.error.message
      @$form.find('button').prop 'disabled', false
    else 
      # token contains id, last4, and card type
      token = response.id
      # Insert the token into the form so it gets submitted to the server
      # $form.append($('<input type="hidden" name="stripeToken" />').val(token));
      # // and submit   
      @model.save tempToken: token, { success: @stripeCustomerSuccess }

  stripeCustomerSuccess: (model, resp, opts) =>
    $log 'got a customer yeah!', model.attributes

    @$el.html 'success'


module.exports = exports