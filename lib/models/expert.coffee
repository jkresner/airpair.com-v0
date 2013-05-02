mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId;

  # thread: ObjectId
  # date: {type: Date, default: Date.now}
  # author: {type: String, default: 'Anon'}

schema = new Schema
  userId:         { type: ObjectId }  # TODO should make required for v0.5
  name:           { required: true, type: String   }
  username:       { required: true, type: String   }
  email:          { required: true, type: String   }
  gmail:          { required: true, type: String   }
  pic:            { required: true, type: String   }
  homepage:       String      # homepage
  sideproject:    String      # sideproject Url
  other:          String      # other url
  gh:             {}          # github
  so:             {}          # stackoverflow
  bb:             {}          # bitbucket
  in:             {}          # linkedIn
  tw:             {}          # twitter
  tags:           [{}]
  rate:           Number
  timezone:       String
  location:       String
  brief:          String
  karma:          { required: true, type: Number, default: 0 }
  status:         String
  hours:          String
  helloUrl:       String

module.exports = mongoose.model 'Expert', schema