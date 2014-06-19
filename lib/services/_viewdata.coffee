# async            = require 'async'
TagsSvc          = require '../services/tags'
OrdersSvc        = require '../services/orders'
ExpertsSvc       = require '../services/experts'
CompanysSvc      = require '../services/companys'
# SettingsSvc      = require '../services/settings'
RequestsSvc      = require '../services/requests'
stripePK         = cfg.payment.stripe.publishedKey

module.exports = class ViewDataService

  logging: off

  constructor: (user) ->
    @usr = user

  # session gets called from viewRender.render
  session: (full) ->
    if @usr? && @usr.google?
      u = _.clone @usr
      if u.google then delete u.google.token
      if u.twitter then delete u.twitter.token
      if u.bitbucket then delete u.bitbucket.token
      if u.github then delete u.github.token
      if u.stack then delete u.stack.token
      u.authenticated = true
      if full
        u
      else
        _.pick u, ['_id','google','googleId','authenticated']
    else
      authenticated : false

  settings: (cb) ->
    cb null, -> { stripePK }

  beexpert: (cb) ->
    session = @session true
    cb null, -> { session }

  dashboard: (cb) ->
    cb null, -> { }

  review: (id, cb) ->
    new RequestsSvc(@usr).getByIdSmart id, (e, request) =>
      cb e, -> { request }

  callSchedule: (requestId, cb) ->
    new RequestsSvc(@usr).getById requestId, (e, request) =>
      new OrdersSvc(@usr).getByRequestId request._id, (ee, orders) =>
        cb ee, -> { request, orders }

  callEdit: (callId, cb) ->
    new RequestsSvc(@usr).getByCallId callId, (e, request) =>
      new OrdersSvc(@usr).getByRequestId request._id, (ee, orders) =>
        cb ee, -> { request, orders }

  book: (id, code, cb) ->
    new ExpertsSvc(@user).getByBookme id, code, (e, expert) =>
      cb e, -> { expert, stripePK }

  history: (id, cb) ->
    new RequestsSvc(@usr).getForHistory id, (e,requests) =>
      new OrdersSvc(@usr).getForHistory id, (ee,orders) =>
        cb ee, -> { orders, requests }

  bookme: (cb) ->
    githubToken = if @usr.github.token? then @usr.github.token.token else ''
    new ExpertsSvc(@usr).getByBookmeByUserId @usr._id, (e, expert) =>
      cb e, -> { expert, githubToken }

  pipeline: (cb) ->
    new RequestsSvc(@usr).getActive (e, requests) =>
      cb e, -> { requests }

  orders: (cb) ->
    new OrdersSvc(@usr).getAll (e, orders) =>
      cb e, -> { orders }

  ordersang: (cb) -> @orders cb

  experts: (cb) ->
    new ExpertsSvc(@usr).getAll (e, experts) =>
      cb e, -> { experts }

  companys: (cb) ->
    new CompanysSvc(@usr).getAll (e, companys) =>
      cb e, -> { companys, stripePK }

  so10: (id, cb) ->
    id = 'c++' if id is 'c%2b%2b'
    id = 'c#' if id is 'c%23'
    new TagsSvc(@usr).getBySoId id, (e, tag) =>
      feature = name:'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
      feature = name:'Ran Nachmany', me: 'rannachmany', claim: 'Android Google Developer Expert' if id is 'android'
      feature = name:'Matias Niemelä', me: 'matsko', claim: 'AngularJS Core Team' if id is 'angularjs'
      feature = name:'Phil Sturgeon', me: 'philsturgeon', claim: 'PHP Top Answerer' if id is 'php'
      feature = name:'Tim Caswell', me: 'creationix', claim: 'Early Node.js Contributor' if id is 'node.js'
      feature = name:'Wain Glaister', me: 'wain', claim: 'iOS Top Answerer' if id is 'ios'
      feature = name:'Amir Rajan', me: 'amirrajan', claim: 'ASP .net AirPair Expert' if id is 'asp.net'
      feature = name:'Steve Purves', me: 'stevejpurves', claim: 'C++ AirPair Expert' if id is 'c++'
      feature = name:'John Feminella', me: 'john-feminella', claim: 'C# Top Answerer' if id is 'c#'
      feature = name:'Marko Topolnik', me: 'marko', claim: 'Java Top Answerer' if id is 'java'
      cb e, -> { tag, feature }


  paypalSuccess: (id, cb) ->
    new OrdersSvc(@usr).markPaymentReceived id, {}, (e, order) =>
      cb e, -> { order }

  paypalCancel: (id, cb) ->
    new OrdersSvc(@usr).getById id, (e, order) =>
      cb e, -> { order }


