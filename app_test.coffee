tagsData = require './test/data/tags'
tagModel = require './lib/models/tag'

module.exports = (app) ->

  app.use require('./test/server/test-passport').initialize app

  app.get '/seeddata', (req, res)-> 
    tagModel.create tagsData, (err, result) ->
      res.send(err? ? 500: 200)

  app.get '/unseeddata', (req, res) -> 
    tagModel.remove {}, (err, result) ->
      res.send(err? ? 500: 200)