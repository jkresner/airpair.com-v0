mongoose = require 'mongoose'
Schema = mongoose.Schema
{ObjectId, Mixed} = Schema.Types


LineItem = new Schema
  total:          { required: true, type: Number }
  unitPrice:      { required: true, type: Number }
  qty:            { required: true, type: Number }
  qtyRedeemed:    { required: true, type: Number, default: 0 }
  type:           { required: true, type: String } # open-source, private, nda
  suggestion:     { required: true, type: {} }


schema = new Schema
  requestId:      { required: true, type: ObjectId, ref: 'Request' }
  userId:         { required: true, type: ObjectId, ref: 'User'    }
  company:        { required: true, type: Mixed    }
  lineItems:      { type: [LineItem] }
  utc:            { type: Date, default: Date }
  total:          { required: true, type: Number   }
  profit:         { required: true, type: Number   }
  invoice:        { required: true, type: {} }     # can reference a 3rd party invoice
  paymentType:    { required: true, type: String   }
  payment:        { required: true, type: {} }
  paymentStatus:  { required: true, type: String, default: 'pending' }


module.exports = mongoose.model 'Order', schema