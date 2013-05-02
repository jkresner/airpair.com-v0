CRUDApi = require './_crud'


class ExpertApi extends CRUDApi

  model: require './../models/expert'

  detail: (req, res) =>

    search = '_id': req.params.id

    if req.params.id is 'me'
      search = userId: req.user._id

    @model.findOne search, (e, r) =>
      if r? then return res.send r
      else
        search = email: req.user.google._json.email
        $log 'detail req.user by email', search
        @model.findOne search, (e, r) =>
          r = {} if r is null
          res.send r


module.exports = (app) -> new ExpertApi app, 'experts'