viewData = new (require './lib/services/_viewdata')()
tagsData = require './test/data/tags'
tagModel = require './lib/models/tag'

module.exports = (app) ->

  app.get '/seeddata', (req, res)->
    tagModel.create tagsData, (err, result) ->
      res.send(err? ? 500: 200)

  app.get '/unseeddata', (req, res) ->
    tagModel.remove {}, (err, result) ->
      res.send(err? ? 500: 200)

  #
  # these wierd routes are here because we don't care to have matching
  # api endpoints for pages that use these viewdata functions
  #

  app.get '/_viewdata/callEdit/:callId', (req, res, next) ->
    viewData.callEdit null, req.params.callId, (err, json) ->
      if err then return next err
      res.send
        request: JSON.parse json.request
        orders: JSON.parse json.orders

  app.get '/_viewdata/calls/:callId/:answer', (req, res, next) ->
    viewData.calls req.user, req.params.callId, req.params.answer, (err, json) ->
      if err then return next err
      res.send calls: JSON.parse json.calls
