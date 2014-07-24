BB = require 'BB'
S = require '../../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  # logging: on

  pushStateRoot: '/airconf-registration'

  routes:
    'register'  : 'register'
    'thanks'    : 'thanks'

  appConstructor: (pageData, callback) ->
    {ticketPrice,pairCredit,paid,confOrder} = pageData.registration
    d =
      page: new BB.BadassModel paid: paid, hasCard: pageData.hasCard, stripePK: pageData.stripePK
      company: new M.Company pageData.company
      order: new M.Order confOrder
    v =
      orderView: new V.OrderView model: d.order, company: d.company, session: @app.session, page: d.page

    if !pageData.company.contacts? || pageData.company.contacts.length == 0
      d.company.populateFromGoogle @app.session

    if !confOrder?
      d.order.set total: ticketPrice, company: d.company.attributes

    v.orderView.render()

    _.extend d, v

  initialize: (args) ->
    if @app.page.get('paid')
      @navTo 'thanks'
    else
      @navTo 'register'
  register: ->

  thanks: ->
