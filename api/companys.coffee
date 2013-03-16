Company = require './../models/company'


exports.clear = -> Company.find({}).remove()


exports.post = (req, res) ->
  new Company( req.body ).save( (err, result) -> res.send result )


exports.list = (req, res) ->
  Company.find( (err, list) -> res.send list )


exports.update = (req, res) ->
  Company.update( req.body, (err, result) -> res.send result )


exports.delete = (req, res) ->
  Company.find( _id: req.params.id ).remove( (err, result) -> res.send result )


exports.show = (req, res) ->
  Company.findOne { _id: req.params.id }, (error, item) -> res.send item