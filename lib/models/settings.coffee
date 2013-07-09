mongoose = require 'mongoose'
Schema = mongoose.Schema
{ObjectId, Mixed} = Schema.Types


PaymentMethod = new Schema
  isPrimary:        { required: true, type: Boolean }
  type:             { required: true, type: String }
  info:             { required: true, type: {} }


Settings = new Schema
  userId:           { type: ObjectId, ref: 'User' }
  paymentMethods:   [PaymentMethod]


module.exports = mongoose.model 'Settings', Settings