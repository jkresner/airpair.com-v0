und = require 'underscore'


class CRUDApi


  show: (req, res) =>
    @model.findOne { _id: req.params.id }, (e, r) -> res.send item


  list: (req, res) =>
    console.log 'list', @
    console.log '@model', @model
    @model.find (e, r) -> res.send list


  post: (req, res) =>
    @model( req.body ).save (e, r) -> res.send r


  update: (req, res) =>
    data = und.clone req.body
    delete data._id # so mongo doesn't complain
    @model.update { _id: req.params.id }, data, (e, r) -> res.send req.body


  delete: (req, res) =>
    @model.find( _id: req.params.id ).remove (e, r) -> res.send r


module.exports = CRUDApi