S = require '../../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/book'

  routes:
    'none'        : 'none'
    'thanks'      : 'thanks'
    ':id'         : 'detail'

  appConstructor: (pageData, callback) ->
    {expert,session,settings} = pageData

    d =
      company: new M.Company _id: 'me'
      expert: new M.Expert()
      settings: new M.Settings()
      request: new M.Request()

    if expert._id?
      v =
        infoFormView: new V.InfoFormView model: d.company, request: d.request
        expertView: new V.ExpertView model: d.expert, request: d.request, session: @app.session
        requestView: new V.RequestView model: d.request, settings: d.settings, expert: d.expert, company: d.company

    if !session._id? && expert._id?
      v.welcomeView = new V.WelcomeView model: d.expert
    else if session._id?
      @setOrFetch d.settings, settings, success: (model, resp) =>
        if !model.paymentMethod('stripe')?
          v.stripeRegisterView = new V.StripeRegisterView model: d.settings, session: @app.session, expert: d.expert
          v.stripeRegisterView.$el.show()
          Stripe.setPublishableKey pageData.stripePK

      d.company.fetch success: (m, opts, resp) =>
        m.populateFromGoogle @app.session

    @setOrFetch d.expert, expert

    _.extend d, v

  initialize: (args) ->

  detail: (id) ->
    if !@app.expert.id? then return @none()
    $('#detail').show()

  thanks: ->
    if $('#thanks').html() is ''
      $('#thanks').html require('./templates/ThankYou')(@app.expert.get('name'))




