BB = require './../../lib/BB'
exports = {}

class exports.Source extends BB.BadassModel
  urlRoot: '/api/sources'
  # validation:
    # name: { required: true }

# class exports.TagListModel extends BB.SublistModel
#   defaults:
#     tags: []
#   toggleTag: (value) ->
#     @toggleAttrSublistElement 'tags', value, (m) -> m._id is value._id

module.exports = exports
