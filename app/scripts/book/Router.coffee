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
      stripeRegisterView: new V.StripeRegisterView model: d.settings, session: @app.session
      # requestView: new V.RequestView()
      # signinView: new V.SigninView()

    if pageData.session._id?
      if !pageData.settings?
        a = 1
        # welcomeView: new V.WelcomeView model: d.expert
    else
      welcomeView: new V.WelcomeView model: d.expert

    @setOrFetch d.settings, pageData.settings
    @setOrFetch d.expert, pageData.expert

    Stripe.setPublishableKey pageData.stripePK

    _.extend d, v

  initialize: (args) ->

  detail: (id) ->
    if !@app.expert.id? then return @none()
    $('#detail').show()


