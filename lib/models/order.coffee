mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId


LineItem = new Schema
  total:        { required: true, type: Number }
  unitPrice:    { required: true, type: Number }
  qty:          { required: true, type: Number }
  qtyRedeemed:  { required: true, type: Number, default: 0 }
  type:         { required: true, type: String } # open-source, private, nda
  suggestion:   { required: true, type: {} }


schema = new Schema
  userId:       { type: ObjectId, ref: 'User' }
  email:        { required: true, type: String }
  fullName:     { required: true, type: String }
  lineItems:    { type: [LineItem] }
  utc:          { type: Date, default: Date }
  total:        { required: true, type: Number }
  profit:       { required: true, type: Number }
  invoice:      { required: true, type: {} }     # can reference a 3rd party invoice
  paymentType:  { required: true, type: String }
  payment:      { required: true, type: {} }


module.exports = mongoose.model 'Order', schema