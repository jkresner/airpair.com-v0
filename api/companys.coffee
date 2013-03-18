Company = require './../models/company'

###############################################################################
## Data loading (should be removed soon)
###############################################################################


exports.clear = -> Company.find({}).remove()


###############################################################################
## CRUD
###############################################################################


exports.show = (req, res) ->
  Company.findOne { _id: req.params.id }, (error, item) -> res.send item


exports.list = (req, res) ->
  Company.find (err, list) -> res.send list


exports.post = (req, res) ->
  new Company( req.body ).save (err, result) -> res.send result


exports.update = (req, res) ->
  delete req.body._id
  Company.update({ _id: req.params.id }, req.body, (e, r) -> res.send r )


exports.delete = (req, res) ->
  Company.find( _id: req.params.id ).remove( (err, result) -> res.send result )