S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/book'

  routes:
    'none'  : 'none'
    ':id'   : 'detail'

  appConstructor: (pageData, callback) ->
    d =
      expert: new M.Expert()
      settings: new M.Settings()
      request: new M.Request()
      tags: new C.Tags()
    v =
      expertView: new V.ExpertView model: d.expert
      requestView: new V.RequestView model: d.request, settings: d.settings


    if !pageData.session._id?
      welcomeView: new V.WelcomeView model: d.expert


    @setOrFetch d.expert, pageData.expert
    @setOrFetch d.settings, pageData.settings, success: (model, resp) =>
      if !model.paymentMethod('stripe')?
        v.stripeRegisterView = new V.StripeRegisterView model: d.settings, session: @app.session
        v.stripeRegisterView.$el.show()
        Stripe.setPublishableKey pageData.stripePK

    _.extend d, v

  initialize: (args) ->

  detail: (id) ->
    if !@app.expert.id? then return @none()
    $('#detail').show()




