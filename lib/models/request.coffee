mongoose = require 'mongoose'
Schema   = mongoose.Schema

{ObjectId, Mixed} = Schema.Types


"""
Request status

  received      : requires review by airpair
  incomplete    : more detail required
  holding       : waiting for go ahead by customer
  waiting       : no experts available yet
  pending       : [bookme] customer put in request and expert has to confirm
  review        : customer must review & choose one or more experts
  scheduling    : call needs to be scheduled
  scheduled     : one or more calls already scheduled
  consumed      : feedback on all calls collected, but lead still warm for up-sell
  complete      : transaction final and time to archive
  canceled      : company has canceled the request
  deferred      : customer indicated they need more time

  ** after a user saves info from incomplete state, request goes back into received

Suggestion expertStatus

  waiting       : waiting to hear from the expert
  opened        : expert has looked at request but not replied
  busy          : expert cannot do it within 72 hours, but wants to do it after
  abstained     : expert does not want the call
  underpriced   : expert is available but wants more money
  available     : expert wants the call
  chosen        : customer has booked the expert
  released      : expert wasn't booked within 72 hours
"""

eStatus = ['waiting','opened','busy','abstained','underpriced','available','chosen','released']


Suggestion = new Schema
  events:             [{}]
  expert:             { required: true, type: {} }
  expertStatus:       { required: true, enum: eStatus, type: String, default: 'waiting' }
  expertRating:       Number
  expertFeedback:     String
  expertComment:      String
  expertAvailability: String     # todo change to dates
  suggestedRate:      Number     # can be altered by admin or expert
  customerRating:     Number
  customerFeedback:   String
  matchedBy:          {}


Recording = new Schema
  type: { required: true, type: String }
  data: { required: true, type: Mixed } # YouTube's API response



VALID_CALL_TYPES = ['opensource', 'private', 'nda', 'subscription', 'offline']


Call = new Schema
  # TODO index on subdocument id
  expertId:         { required: true, type: ObjectId, ref: 'Expert', index: true }
  type:             {
                      type: String,
                      enum: VALID_CALL_TYPES,
                      required: true
                    }
  duration:         { required: true, type: Number }
  status:           { required: true, type: String }  # pending, confirmed, declined
  datetime:         { required: true, type: Date, index: true }
  gcal:             { required: true, type: Mixed }
  # expert:           { required: true, type: {} }
  # hours:            { required: true, type: Number }
  recordings:       { required: false, type: [Recording], default: [] }
  notes:            { required: true, type: String }
  # expertEndorsed:   String   # If the expert wants the session featured (or hidden)
  # expertReview:     {}   # Experts feedback on how the session went
  # expertShare:      {}   # Tacking Expert sharing activity
  # customerReview:   {}   # Customer's feedback on how the session went
  # customerShare:    {}   # Tacking Customer sharing activity
  # cms:              {}   # title, transcript, expertMeta, customerMeta
  # cmsStatus:        { request: true, type: String, default: 'nocontent' }  # nocontent, pending, incomplete, approved
  # cmsPermalink:     { required: true, type: ObjectId, unique: true, sparse: true } # index for quick search
  # airpairRating:    { type: Number }  # How we sort session by awesomeness


RequestSchema = new Schema
  userId:           { required: true, type: ObjectId, ref: 'User', index: true }
  by:               {}
  company:          { required: true, type: Mixed }
  tags:             [{}]
  marketingTags:    { type: [{}], default: [] }
  owner:            String
  brief:            { required: true, type: String   }
  budget:           { required: true, type: Number   }
  hours:            { required: true, type: String   }
  pricing:          { required: true, type: String, enum: VALID_CALL_TYPES   }
  events:           { required: true, type: [{}]     }
  status:           { required: true, type: String   } # TODO add cancelled, use enum
  incompleteDetail: String
  canceledDetail:   String
  timezone:         String
  availability:     String
  suggested:        [Suggestion]
  calls:            [Call]

module.exports = mongoose.model 'Request', RequestSchema
