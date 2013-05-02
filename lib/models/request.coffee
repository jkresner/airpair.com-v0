mongoose = require 'mongoose'
Schema = mongoose.Schema
{ObjectId, Mixed} = Schema.Types

"""
Request status

  received      : requires review by airpair
  incomplete    : more detail required
  review        : company must review & choose one or more developers
  scheduled     : one or more airpairs scheduled
  complete      : feedback on all calls collected
  canceled      : company has canceled the request

  ** after a user saves info from incomplete state, request goes back into received

Suggestion expertStatus

  waiting       : waiting to hear from the developer
  abstained     : if developer does not want the call
  available     : developer wants the call
"""

Suggestion = new Schema
  events:             [{}]
  expert:             { required: true, type: {} }
  expertStatus:       { required: true, type: String }
  expertRating:       Number
  expertFeedback:     String
  expertComment:      String
  expertAvailability: [Date]
  customerRating:     Number
  customerFeedback:   String
  messageThreadId:    ObjectId

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
  userId:           { required: true, type: ObjectId, index: true }
  company:          { required: true, type: Mixed    }
  tags:             [{}]
  brief:            { required: true, type: String   }
  budget:           { required: true, type: Number   }
  hours:            { required: true, type: String   }
  pricing:          { required: true, type: String   }
  events:           { required: true, type: [{}]  }
  status:           { required: true, type: String   }
  incompleteDetail: String
  canceledReason:   String
  timezone:         String
  availability:     String
  suggested:        [Suggestion]
  calls:            [Call]


module.exports = mongoose.model 'Request', schema