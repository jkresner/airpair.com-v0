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
      selectedUser: new M.User()
      users: new C.Users()
      companys: new C.Companys()
      sharedCards: new C.PayMethods()
      selectedCard: new M.PayMethod()
    v =
      companysView: new V.CompanysView collection: d.companys, model: d.selected
      cardsView: new V.CardsView collection: d.sharedCards
      cardEditView: new V.CardEditView model: d.selectedCard, collection: d.sharedCards
      # stripeRegisterView: new V.StripeRegisterView model: d.sharedCards, session: @app.session

      # usersView: new V.UsersView collection: d.users, model: d.selected
      # userView: new V.UserView model: d.selected

    # @resetOrFetch d.users, pageData.users
    # @resetOrFetch d.companys, pageData.companys
    @resetOrFetch d.sharedCards, null

    Stripe.setPublishableKey pageData.stripePK if Stripe?

    _.extend d, v

  initialize: (args) ->
    @navTo 'list'

  edit: (id) ->
    user = @app.users.findWhere _id: id
    # $log 'editing user', user.toJSON()
    # $('#editheading').html user.get('google').displayName
    @app.selected.set user.attributes

  editcard: (id) ->
    card = @app.sharedCards.findWhere { '_id': id }
    if !card? then @navTo 'list'

    @app.selectedCard.clear silent:true
    @app.selectedCard.set card.attributes
