# async            = require 'async'
Data             = require './_viewdata.data'
TagsSvc          = require '../services/tags'
OrdersSvc        = require '../services/orders'
ExpertsSvc       = require '../services/experts'
CompanysSvc      = require '../services/companys'
# SettingsSvc      = require '../services/settings'
RequestsSvc      = require '../services/requests'
stripePK         = config.payment.stripe.publishedKey
segmentioKey     = config.analytics.segmentio.writeKey

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
    cb null, -> { stripePK, segmentioKey }

  beexpert: (cb) ->
    session = @session true
    cb null, -> { session, segmentioKey }

  dashboard: (cb) ->
    cb null, -> { segmentioKey }

  review: (id, cb) ->
    new RequestsSvc(@usr).getByIdSmart id, (e, request) =>
      cb e, -> { request, segmentioKey }

  schedule: (requestId, cb) ->
    new RequestsSvc(@usr).getById requestId, (e, request) =>
      if !request? then return cb e, -> {}
      new OrdersSvc(@usr).getByRequestId request._id, (ee, orders) =>
        cb ee, -> { request, orders, segmentioKey }

  book: (id, code, cb) ->
    new ExpertsSvc(@user).getByBookme id, code, (e, expert) =>
      cb e, -> { expert, stripePK, segmentioKey }

  history: (id, cb) ->
    new RequestsSvc(@usr).getForHistory id, (e,requests) =>
      new OrdersSvc(@usr).getForHistory id, (ee,orders) =>
        cb ee, -> { orders, requests, segmentioKey }

  bookme: (cb) ->
    githubToken = if @usr.github.token? then @usr.github.token.token else ''
    new ExpertsSvc(@usr).getByBookmeByUserId @usr._id, (e, expert) =>
      cb e, -> { expert, githubToken, segmentioKey }

  pipeline: (cb) ->
    new RequestsSvc(@usr).getActive (e, requests) =>
      cb e, -> { requests, segmentioKey }

  orders: (cb) ->
    new OrdersSvc(@usr).getAll (e, orders) =>
      cb e, -> { orders, segmentioKey }

  ordersang: (cb) -> @orders cb

  experts: (cb) ->
    new ExpertsSvc(@usr).getAll (e, experts) =>
      cb e, -> { experts, segmentioKey }

  companys: (cb) ->
    new CompanysSvc(@usr).getAll (e, companys) =>
      cb e, -> { companys, stripePK, segmentioKey }

  speakers: (cb) ->
    cb null, -> { speakers: Data.speakers, segmentioKey }

  home: (cb) ->
    cb null, -> { segmentioKey }

  so10: (id, cb) ->
    id = 'c++' if id is 'c%2b%rub2b'
    id = 'c#' if id is 'c%23'
    new TagsSvc(@usr).getBySoId id, (e, tag) =>
      feature = name:'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
      feature = Data.so10[id] if Data.so10[id]
      cb e, -> { tag, feature, segmentioKey }

  so11: (id, cb) -> @so10 id, cb
  so12: (id, cb) -> @so10 id, cb
  so12re: (id, cb) -> @so10 id, cb
  so13: (id, cb) -> @so10 id, cb
  so14: (id, cb) -> @so10 id, cb

  so15: (id, cb) ->
    id = 'c++' if id is 'c%2b%2b'
    id = 'c#' if id is 'c%23'
    id = 'ruby-on-rails' if id is 'rails'
    new TagsSvc(@usr).getBySoId id, (e, tag) =>
      feature = name:'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
      feature = Data.so15[id] if Data.so15[id]
      cb e, -> { tag, feature, segmentioKey }

  so16: (id, cb) -> @so15 id, cb
  so17: (id, cb) -> @so15 id, cb
  so18: (id, cb) -> @so15 id, cb
  so19: (id, cb) -> @so15 id, cb

  bsa02: (id, cb) ->
    id = 'c++' if id is 'c%2b%2b'
    id = 'c#' if id is 'c%23'
    new TagsSvc(@usr).getBySoId id, (e, tag) =>
      feature = name:'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
      feature = Data.so15[id] if Data.so15[id]
      cb e, ->
        console.log "BSA02 -- #{id}"
        return { tag, feature }


  paypalSuccess: (id, cb) ->
    new OrdersSvc(@usr).markPaymentReceived id, {}, (e, order) =>
      cb e, -> { order, segmentioKey }

  paypalCancel: (id, cb) ->
    new OrdersSvc(@usr).getById id, (e, order) =>
      cb e, -> { order, segmentioKey }


