mongoose = require 'mongoose'

module.exports = (app, express) ->
  mongoose.connect cfg.mongoUri
  db = mongoose.connection

  db.on 'error', ->
    console.error.bind console, 'connection error:'

  db.once 'open', ->
    console.log "connected to db #{cfg.mongoUri}"

  MongoSessionStore: require('connect-mongo')(express)
