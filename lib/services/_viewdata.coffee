# async            = require 'async'
AirConfDiscounts  = require '../services/airConfDiscounts'
CompanysSvc = require '../services/companys'
Data = require './_viewdata.data'
ExpertsSvc = require '../services/experts'
OrdersSvc = require '../services/orders'
RequestsSvc = require '../services/requests'
SettingsSvc = require '../services/settings'
stripePK = config.payment.stripe.publishedKey
TagsSvc = require '../services/tags'

module.exports = class ViewDataService

  logging: off

  constructor: (user) ->
    @usr = user

  # session gets called from viewRender.render
  session: (full) ->
    if @usr? && @usr.google?
      u = @usr
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

  automatch: (tags, cb) ->
    cb null, -> {}

  dashboard: (cb) ->
    cb null, -> { showFaqLink: true }

  site: (cb) ->
    cb null, => { session: @session(true) }

  settings: (cb) ->
    cb null, -> { stripePK }

  beexpert: (cb) ->
    cb null, => { session: @session(true) }

  review: (id, cb) ->
    new RequestsSvc(@usr).getByIdSmart id, (e, request) =>
      cb e, -> { request }

  schedule: (requestId, cb) ->
    new RequestsSvc(@usr).getById requestId, (e, request) =>
      if !request? then return cb e, -> {}
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

  airconf: (cb) ->
    if @usr?
      new OrdersSvc(@usr).getAirConfRegisration (e, registration) =>
        cb e, -> { workshops: Data.workshops, registration }
    else
      cb null, -> { workshops: Data.workshops }

  airconfsession: (id, cb) ->
    workshop = _.find Data.workshops, (s) -> s.slug == id
    cb null, -> { workshops: Data.workshops, workshop }

  airconfreg: (cb) ->
    new CompanysSvc(@usr).getById 'me', (e, company) =>
      new OrdersSvc(@usr).getAirConfRegisration (eee, registration) =>
        new SettingsSvc(@usr).getByUserId @usr._id, (ee, settings) =>
          hasCard = _.find(settings.paymentMethods, (p) -> p.type == 'stripe')?
          cb eee, -> { workshops: Data.workshops, hasCard, registration, company, stripePK }

  airconfpromo: (id, cb) ->
    AirConfDiscounts.lookup id, (e, promo) =>
      if e then promo = _.extend e, promo

      # set on the session ? or pass through query string
      cb null, -> { promo }

  airconfpromoconsole: (code, cb) ->
    AirConfDiscounts.lookup code, (e, promo) =>
      console.log 'AirConfDiscounts.lookup', promo
      if e then promo = _.extend e, promo
      cb null, -> { promo }

  so10: (id, cb) ->
    id = 'c++' if id is 'c%2b%rub2b'
    id = 'c#' if id is 'c%23'
    new TagsSvc(@usr).getBySoId id, (e, tag) =>
      feature = name:'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
      feature = Data.so10[id] if Data.so10[id]
      cb e, -> { tag, feature }

  so11: (id, cb) -> @so10 id, cb
  so12: (id, cb) -> @so10 id, cb
  so13: (id, cb) -> @so10 id, cb
  so14: (id, cb) -> @so10 id, cb

  so15: (id, cb) ->
    id = 'c++' if id is 'c%2b%2b'
    id = 'c#' if id is 'c%23'
    id = 'ruby-on-rails' if id is 'rails'
    new TagsSvc(@usr).getBySoId id, (e, tag) =>
      feature = name:'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
      feature = Data.so15[id] if Data.so15[id]
      cb e, -> { tag, feature }

  so16: (id, cb) -> @so15 id, cb
  so17: (id, cb) -> @so15 id, cb
  so18: (cb) -> cb null, -> { stripePK }
  so19: (cb) -> cb null, -> { stripePK }


  bsa02: (cb) ->
    cb null, -> { stripePK }

  paypalSuccess: (id, cb) ->
    new OrdersSvc(@usr).markPaymentReceived id, {}, (e, order) =>
      cb e, -> { order }

  paypalCancel: (id, cb) ->
    new OrdersSvc(@usr).getById id, (e, order) =>
      cb e, -> { order }


