Order = require '../models/order'

#
# this is here b/c otherwise we'd create a circular require between the
# request service and the orders service.
#

# copy owner and marketingTags to every associated order.
module.exports = setMarketingTagsOnOrders = (requestId, marketingTags, owner, callback) =>
  query = requestId: requestId
  updates = $set: { marketingTags: marketingTags, owner: owner || '' }
  Order.update query, updates, multi: true, callback
