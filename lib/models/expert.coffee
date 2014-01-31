mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId;


# This object Allows our experts to charge different amount to different customers
Coupon =
  code:           { required: true, type: String }
  rate:           { required: true, type: Number }


# # # This object helps us to motivate our experts to promote us
# # # E.g. if they do a certain amount of hours we change our rake and they
# # # Get paid more.
Affiliate =
  rake:           { required: true, type: Number, default: 30 }     # E.g. 30%


# This object helps lets us build a landing page for an expert
Bookme =
  enabled:        { required: true, type: Boolean    }  # allow us or the expert to turn themselves off
  urlSlug:        { required: true, type: String     }  # https://www.airpair.com/@domenic (urlSlug == 'domnic')
  urlBitly:       { required: true, type: String     }  # urlBitly == http://airpa.ir/book-domenic
  urlBlog:        String                                # www.airpair.com/node.js/expert-training-domenic-denicola
  rate:           { required: true, type: Number     }  # experts external rate
  # coupons:        {}                                    # allow the expert to hand out promotions
  affiliate:      { required: true, type: Affiliate  }  # allow the expert commission deals


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
  bookMe:         Bookme


module.exports = mongoose.model 'Expert', schema
