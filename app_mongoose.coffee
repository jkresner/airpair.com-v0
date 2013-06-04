module.exports = (app, express) ->

  mongoose = require 'mongoose'

  app.set 'mongoUri', process.env.MONGOHQ_URL || "mongodb://localhost/#{cfg.db}"

  mongoose.connect app.get 'mongoUri'

  db = mongoose.connection

  db.on 'error', ->
    console.error.bind console, 'connection error:'

  db.once 'open', ->
    console.log "connected to db #{app.get('mongoUri')}"

  MongoSessionStore: require('connect-mongo')(express)