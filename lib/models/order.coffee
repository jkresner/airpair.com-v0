mongoose          = require 'mongoose'
Schema            = mongoose.Schema
{ObjectId, Mixed} = Schema.Types


ExpertPayout = new Schema
  type:           { required: true, type: String } # paypal, coinbase, mtgox etc.
  lineItemId:     { required: true, type: ObjectId, ref: 'LineItem' }
  req:            { required: true, type: Mixed } # Will have provider paymentId
  res:            { required: true, type: Mixed }
  status:         { required: true, type: String } # success, error

# NOT a sub-document
RedeemedCall =
  callId:            { required: true, type: ObjectId, ref: 'Call' }
  # scheduled/pending calls
  qtyRedeemed:       { required: true, type: Number }
  # number of hours that have recordings for them
  qtyCompleted:      { required: true, type: Number, default: 0 }

LineItem = new Schema
  total:              { required: true, type: Number }
  unitPrice:          { required: true, type: Number }
  # total number of hours the customer bought
  qty:                { required: true, type: Number }

  redeemedCalls:      [RedeemedCall]
  type:               { required: true, type: String } # opensource, private, nda
  suggestion:         { required: true, type: {} }

schema = new Schema
  requestId:      { required: true, type: ObjectId, ref: 'Request' }
  userId:         { required: true, type: ObjectId, ref: 'User'    }
  company:        { required: true, type: Mixed  }
  lineItems:      { type: [LineItem] }
  utc:            { type: Date, default: Date }
  total:          { required: true, type: Number   }
  profit:         { required: true, type: Number   }
  invoice:        { required: true, type: {} }     # can reference a 3rd party invoice
  paymentType:    { required: true, type: String   }
  payment:        { required: true, type: {} }
  payouts:        { type: [ExpertPayout] }
  paymentStatus:  { required: true, type: String, default: 'pending' }
  # when a request is saved, this gets copied over from request.owner
  owner:          { type: String, default: '' }
  # when a request is saved, this gets copied over from request.marketingTags
  marketingTags:  { type: [{}], default: [] }

module.exports = mongoose.model 'Order', schema
