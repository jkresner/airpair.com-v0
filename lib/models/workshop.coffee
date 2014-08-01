mongoose          = require 'mongoose'
Schema            = mongoose.Schema
{ObjectId, Mixed} = Schema.Types


Attendee = new Schema
  userId:          { required: true, type: ObjectId, ref: 'User' }
  orderId:         { required: true, type: ObjectId, ref: 'Order' }

schema = new Schema
  slug:            { required: true, type: String, index: { unique: true } }
  title:           String
  description:     String
  difficulty:      String
  speakers:        { required: true, type: [Mixed]  }
  time:            Date
  attendees:       { type: [Attendee], default: [] }
  duration:        String
  updatedAt:       { type: Date, default: Date }
  price:           { required: true, type: Number }
  tags:            { type: [String], default: [] }
  public:          { type: Boolean, default: false }

module.exports = mongoose.model 'Workshop', schema
