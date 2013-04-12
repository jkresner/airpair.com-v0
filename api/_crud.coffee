und = require 'underscore'


class CRUDApi

###############################################################################
## Data loading / clearing (should only be used when necessary)
###############################################################################

  # clear: -> @model.find({}).remove()

###############################################################################
## Standard CRUD
###############################################################################

  detail: (req, res) =>
    @model.findOne { _id: req.params.id }, (e, r) -> res.send r


  list: (req, res) =>
    @model.find (e, r) -> res.send r


  post: (req, res) =>
    @model( req.body ).save (e, r) -> res.send r


  update: (req, res) =>
    # @model.findByIdAndUpdate req.params.id, req.params, (e, r) -> res.send r
    data = und.clone req.body
    delete data._id # so mongo doesn't complain
    @model.update { _id: req.params.id }, data, (e, r) -> res.send req.body


  delete: (req, res) =>
    @model.find( _id: req.params.id ).remove (e, r) -> res.send r


module.exports = CRUDApi