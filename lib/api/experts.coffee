CRUDApi = require './_crud'


class ExpertApi extends CRUDApi

  model: require './../models/expert'

  detail: (req, res) =>

    search = '_id': req.params.id

    if req.params.id is 'me'
      search = userId: req.user._id

    @model.findOne search, (e, r) ->
      r = {} if r is null
      res.send r


module.exports = (app) -> new ExpertApi app,'experts'