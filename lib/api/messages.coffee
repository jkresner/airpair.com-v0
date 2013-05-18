#CRUDApi = require './_crud'
crudFn = require './crudFN'


class MessageApi extends CRUDApi

  model: require './../models/message'

  create: (req, res) =>

    req.body.from = req.user._id

    new @model( req.body ).save (e, r) =>
      if @logging then $log 'created:', e, r
      res.send r

  list: (req, res) =>
    uid = req.user._id
    @model.find {$or: [{from: uid}, {to: uid}]}, (e, r) -> res.send r


#module.exports = (app) -> new MessageApi app, 'messages'
module.exports = (app) ->
  model = require './../models/message'
  route = 'messages'
  app.put "/api/#{route}/:id", authz(), (req, res) ->
    #custom logic
    crudFn.update model, route, req res
  crudFn app,
  app.post "/api/#{route}", authz(), crudFn.baseCreate(model)
