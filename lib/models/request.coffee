mongoose = require 'mongoose'
Schema = mongoose.Schema
{ObjectId, Mixed} = Schema.Types

"""
Request status

  received      : requires review by airpair
  incomplete    : more detail required
  review        : company must review & choose one or more developers
  scheduled     : one or more airpairs scheduled
  completed     : feedback on all calls collected
  canceled      : company has canceled the request

  ** after a user saves info from incomplete state, request goes back into received

Suggestion status

  awaiting   : waiting on the developer for availability & relevance
  passed        : if developer is not available or
  available     : developer would like to take the call
  booked        : developer has been booked for an airpair

"""

Suggestion = new Schema
  status:           String
  events:           [{}]
  expert:           {}
  availability:     [Date]
  comment:          String


Call = new Schema
  expert:           {}
  time:             Date
  recordingUrls:    []
  type:             String        # opensource, private, subscription
  devRate:          Number
  fee:              Number
  review:           String
  devEndorsed:      String


schema = new Schema
  userId:           { required: true, type: ObjectId }
  company:          { required: true, type: Mixed    }
  tags:             [{}]
  brief:            { required: true, type: String   }
  budget:           { required: true, type: Number   }
  hours:            { required: true, type: String   }
  pricing:          { required: true, type: String   }
  events:           { required: true, type: [{}]  }
  status:           { required: true, type: String   }
  canceledReason:   String
  availability:     [Date]
  suggested:        [Suggestion]
  calls:            [Call]


module.exports = mongoose.model 'Request', schema