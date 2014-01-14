BB = require './../../lib/BB'
Shared = require './../shared/Models'
exports = {}

class exports.MarketingTag extends BB.BadassModel
  urlRoot: '/api/marketingtags'
  # validation:
    # name: { required: true }

# class exports.TagListModel extends BB.SublistModel
#   defaults:
#     tags: []
#   toggleTag: (value) ->
#     @toggleAttrSublistElement 'tags', value, (m) -> m._id is value._id
exports.Request = Shared.Request

module.exports = exports
