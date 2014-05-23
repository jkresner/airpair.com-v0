BB = require 'BB'
exports = {}


class exports.Tag extends BB.BadassModel

  urlRoot: '/api/tags'

  validation:
    name:           { required: true }



class exports.TagListModel extends BB.SublistModel

  defaults:
    tags: []

  toggleTag: (value) ->
    @toggleAttrSublistElement 'tags', value, (m) -> m._id is value._id



module.exports = exports
