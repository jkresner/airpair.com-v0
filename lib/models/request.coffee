mongoose = require 'mongoose'
Schema = mongoose.Schema

{ObjectId, Mixed} = Schema.Types

"""
Request status

  received      : requires review by airpair
  incomplete    : more detail required
  holding       : waiting for go ahead by customer
  review        : customer must review & choose one or more experts
  scheduled     : one or more airpairs scheduled
  complete      : feedback on all calls collected
  canceled      : company has canceled the request

  ** after a user saves info from incomplete state, request goes back into received

Suggestion expertStatus

  waiting       : waiting to hear from the expert
  abstained     : expert does not want the call
  available     : expert wants the call
  unwanted      : customer does not want the expert
"""

Suggestion = new Schema
  events:             [{}]
  expert:             { required: true, type: {} }
  expertStatus:       { required: true, type: String }
  expertRating:       Number
  expertFeedback:     String
  expertComment:      String
  expertAvailability: String     # todo change to dates
  suggestedRate:      Number     # can be altered by admin or expert
  customerRating:     Number
  customerFeedback:   String


Call = new Schema
  expertId:         { required: true, type: ObjectId, ref: 'Expert', index: true }
  expert:           { required: true, type: {} }
  hours:            { required: true, type: Number }
  type:             String   # opensource, private, nda, subscription, off-line
  status:           { required: true, type: String }  # pending, confirmed, declined
  time:             { required: true, type: Date, index: true }
  gCal:             { required: true, type: {} }
  recordings:       { required: true, type: [{}] }
  expertEndorsed:   String   # If the expert wants the session featured (or hidden)
  expertReview:     {}   # Experts feedback on how the session went
  expertShare:      {}   # Tacking Expert sharing activity
  customerReview:   {}   # Customer's feedback on how the session went
  customerShare:    {}   # Tacking Customer sharing activity
  cms:              {}   # title, transcript, expertMeta, customerMeta
  cmsStatus:        { request: true, type: String, default: 'nocontent' }  # nocontent, pending, incomplete, approved
  cmsPermalink:     { required: true, type: ObjectId, unique: true, sparse: true } # index for quick search
  airpairRating:    { type: Number }  # How we sort session by awesomeness


RequestSchema = new Schema
  userId:           { required: true, type: ObjectId }
  company:          { required: true, type: Mixed    }
  tags:             [{}]
  owner:            String
  brief:            { required: true, type: String   }
  budget:           { required: true, type: Number   }
  hours:            { required: true, type: String   }
  pricing:          { required: true, type: String   }
  events:           { required: true, type: [{}]     }
  status:           { required: true, type: String   }
  incompleteDetail: String
  canceledDetail:   String
  timezone:         String
  availability:     String
  suggested:        [Suggestion]
  calls:            [Call]

module.exports = mongoose.model 'Request', RequestSchema
