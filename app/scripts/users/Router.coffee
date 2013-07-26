S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/users'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    'list'        : 'list'
    'edit'        : 'edit'

  appConstructor: (pageData, callback) ->
    d =
      selected: new M.User()
      users: new C.Users()
    v =
      usersView: new V.UsersView collection: d.users, model: d.selected
      # userView: new V.UserView el: '#userPreview', model: d.selected

    @resetOrFetch d.users, pageData.users

    _.extend d, v

  initialize: (args) ->
    @navTo 'list'