CRUDApi = require './_crud'


class CompanyApi extends CRUDApi

  model: require './../models/company'

  detail: (req, res) =>

    search = '_id': req.params.id

    if req.params.id is 'me'
      search = 'contacts.userId': req.user._id

    @model.findOne search, (e, r) ->
      r = {} if r is null
      res.send r


module.exports = (app) -> new CompanyApi app, 'companys'