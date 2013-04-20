mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId;

  # thread: ObjectId
  # date: {type: Date, default: Date.now}
  # author: {type: String, default: 'Anon'}

schema = new Schema
  userId:         { required: true, type: ObjectId }
  name:           { required: true, type: String   }
  username:       { required: true, type: String   }
  email:          { required: true, type: String   }
  gmail:          { required: true, type: String   }
  pic:            { required: true, type: String   }
  homepage:       String      # homepage
  sideproject:    String      # sideproject Url
  otherUrl:       String
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
  currentStatus:  String


module.exports = mongoose.model 'Expert', schema