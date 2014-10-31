mongoose = require 'mongoose'

module.exports = (express=null) ->
  mongoose.connect config.mongoUri
  db = mongoose.connection

  db.on 'error', ->
    console.error.bind console, 'connection error:'

  db.once 'open', ->
    console.log "connected to db #{config.mongoUri}"

  if express?
    MongoSessionStore = require('connect-mongo')(express)
    storeOptions = url: "#{config.mongoUri}/v1sessions", auto_reconnect: true

    new MongoSessionStore storeOptions
  else
    mongoose
