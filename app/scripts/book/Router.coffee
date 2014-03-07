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
      company: new M.Company _id: 'me'
      expert: new M.Expert()
      settings: new M.Settings()
      request: new M.Request { budget: pageData.expert.bookMe.rate }
    v =
      expertView: new V.ExpertView model: d.expert
      requestView: new V.RequestView model: d.request, settings: d.settings, expert: d.expert, company: d.company


    @setOrFetch d.expert, pageData.expert

    if !pageData.session._id?
      v.welcomeView = new V.WelcomeView model: d.expert
    else
      @setOrFetch d.settings, pageData.settings, success: (model, resp) =>
        if !model.paymentMethod('stripe')?
          v.stripeRegisterView = new V.StripeRegisterView model: d.settings, session: @app.session
          v.stripeRegisterView.$el.show()
          Stripe.setPublishableKey pageData.stripePK

      d.company.fetch success: (m, opts, resp) =>
        m.populateFromGoogle d.session

    _.extend d, v

  initialize: (args) ->

  detail: (id) ->
    if !@app.expert.id? then return @none()
    $('#detail').show()




