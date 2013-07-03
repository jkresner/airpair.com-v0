mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId


schema = new Schema
  userId:     { type: ObjectId, ref: 'User' }
  lineItems:  { type: [{}] }
  utc:        { type: Date, default: Date }
  total:      Number
  invoiceId:  String
  paykey:     String

module.exports = mongoose.model 'Order', schema