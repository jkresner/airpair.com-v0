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

  app.get '/_viewdata/callEdit/:callId', (req, res) ->
    viewData.callEdit null, req.params.callId, (err, json) ->
      res.send
        request: JSON.parse json.request
        orders: JSON.parse json.orders
