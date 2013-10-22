util = require './../../app/scripts/util'
RequestsSvc = require './../services/requests'
ExpertsSvc = require './../services/experts'
TagsSvc = require './../services/tags'
OrdersSvc = require './../services/orders'
SettingsSvc = require './../services/settings'
rSvc = new RequestsSvc()
eSvc = new ExpertsSvc()
tSvc = new TagsSvc()
oSvc = new OrdersSvc()
sSvc = new SettingsSvc()  

module.exports = class ViewDataService

  session: (user) ->
    if user? && user.google?
      u = _.clone user
      if u.google then delete u.google.token
      if u.twitter then delete u.twitter.token
      if u.bitbucket then delete u.bitbucket.token
      if u.github then delete u.github.token
      if u.stack then delete u.stack.token
    else
      u = authenticated : false

    JSON.stringify u

  stripeCheckout: (usr, order, callback) ->
    {qty,unitPrice} = order
    total = qty * unitPrice
    pk = global.cfg.payment.stripe.publishedKey
    sSvc.getByUserId usr._id, (r) => 
      callback _.extend {total,qty,unitPrice,pk}, 
        session:    @session usr
        customerId: JSON.stringify r

  review: (id, usr, callback) ->
    rSvc.getByIdSmart id, usr, (r) => callback
      isProd:     cfg.isProd.toString()
      session:    @session usr
      request:    JSON.stringify r
      tagsString: if r? then util.tagsString(r.tags) else 'Not found'

  book: (id, usr, callback) ->
    eSvc.getById id, (r) => callback
      session:    @session usr
      expert:     JSON.stringify r
      expertName: r.name
  inbound: (usr, callback) ->
    tSvc.getAll (t) =>
      eSvc.getAll (e) =>
        rSvc.getActive (r) => callback
          session:  @session usr
          requests: JSON.stringify r
          experts:  JSON.stringify e
          tags:     JSON.stringify t

  landingTag: (tagSearchTerm, usr, callback) ->
    tSvc.search tagSearchTerm, (o) =>
      vd =
        session: @session usr
        tag:     o
      if o?
        vd.tag.img = o.soId
        if o.soId[0] is '.' then vd.tag.img = o.soId.substring(1) # for '.net'
        vd.tag.lowercase_name = vd.tag.name.toLowerCase()
        vd.tag.lowercase_short = vd.tag.short.toLowerCase()
        tSvc.cms o._id, (c) =>
          vd.tagCms = if c? then c else {}
          callback vd
      else
        callback vd

  stripeCharge: (orderId, usr, token, callback) ->
    # oSvc.markPaymentReceived orderId, usr, {}, (o) => callback
    oSvc.markPaymentReceived orderId, usr, {}, (o) => callback
      session: @session usr
      order: JSON.stringify o

  paypalSuccess: (orderId, usr, callback) ->
    oSvc.markPaymentReceived orderId, usr, {}, (o) => callback
      session: @session usr
      order: JSON.stringify o

  paypalCancel: (orderId, usr, callback) ->
    oSvc.getById orderId, (o) => callback
      session: @session usr
      order: JSON.stringify o