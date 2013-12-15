S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'
BB = require './../../lib/BB'

module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/companys'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    '#'                : 'list'
    'list'             : 'list'
    'edit/:id'         : 'edit'
    'addcard'          : 'addcard'
    'editcard/:id'     : 'editcard'

  appConstructor: (pageData, callback) ->
    d =
      selected: new M.User()
      users: new C.Users()
      companys: new C.Companys()
      sharedCards: new M.SharedCards()
      cardUpdates: new BB.BadassModel()
    v =
      companysView: new V.CompanysView collection: d.companys, model: d.selected
      stripeRegisterView: new V.StripeRegisterView model: d.sharedCards, session: @app.session
      cardsView: new V.CardsView model: d.sharedCards
      cardEditView: new V.CardEditView model: d.sharedCards, updates: d.cardUpdates

      # usersView: new V.UsersView collection: d.users, model: d.selected
      # userView: new V.UserView model: d.selected

    # @resetOrFetch d.users, pageData.users
    # @resetOrFetch d.companys, pageData.companys
    @resetOrFetch d.sharedCards, null

    Stripe.setPublishableKey pageData.stripePK

    _.extend d, v

  initialize: (args) ->
    @navTo 'list'

  edit: (id) ->
    user = @app.users.findWhere _id: id
    # $log 'editing user', user.toJSON()
    # $('#editheading').html user.get('google').displayName
    @app.selected.set user.attributes

  editcard: (id) ->
    card = _.find @app.sharedCards.get('paymentMethods'), (m) => m._id == id
    if !card? then @navTo 'list'
    @app.cardUpdates.clear()
    @app.cardUpdates.set card: card
    @app.cardUpdates.trigger 'change'
    $log 'editing Card', card
