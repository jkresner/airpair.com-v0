mongoose = require 'mongoose'
Schema = mongoose.Schema
{ObjectId, Mixed} = Schema.Types


ExpertPayout = new Schema
  type:           { required: true, type: String } # paypal, coinbase, mtgox etc.
  lineItemId:     { required: true, type: ObjectId, ref: 'LineItem' }
  req:            { required: true, type: Mixed } # Will have provider paymentId
  res:            { required: true, type: Mixed }
  status:         { required: true, type: String } # success, error


LineItem = new Schema
  total:              { required: true, type: Number }
  unitPrice:          { required: true, type: Number }

  # total number of hours the customer bought
  qty:                { required: true, type: Number }

  # number of hours that have recordings for them
  qtyCompleted:       { required: true, type: Number, default: 0 }

  # scheduled/pending calls
  qtyRedeemedCallIds: { type: Array, default: [] }

  type:               { required: true, type: String } # open-source, private, nda
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
  utm:            { required: false, type: {} }


module.exports = mongoose.model 'Order', schema
