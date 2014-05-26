{dbConnect,dbDestroy} = require './test-lib-setup'
mongoose              = require 'mongoose'
global.suiteCtx       = true

describe "Server-side suite", ->

  before (done) ->
    @timeout 10000
    dbConnect ->
      mongoose.connection.db.executeDbCommand { dropDatabase: 1 }, done

  describe 'mix/tags', (done) -> require './mix/tags'
  describe 'api/companys', (done) -> require './api/companys'
  describe 'api/experts', (done) -> require './api/experts'
  describe 'api/orders', (done) -> require './api/orders'
  describe 'api/requests', (done) -> require './api/requests'
  describe 'services/orders', (done) -> require './services/orders'
  describe 'services/rates', (done) -> require './services/rates'
  describe 'services/request', (done) -> require './services/request'
  describe 'services/requestCalls', (done) -> require './services/requestCalls'
  describe 'mail/mailman', (done) -> require './mail/mailman'

  after (done) ->
    suiteCtx = false
    dbDestroy @, done
