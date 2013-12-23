global.suiteCtx = true
{dbConnect,dbDestroy} = require './test-lib-setup'
mongoose = require 'mongoose'

describe "Server-side suite", ->

  before dbConnect

  describe 'ui/models/request', (done) -> require './ui/models/request'
  describe 'api/companys', (done) -> require './api/companys'
  describe 'api/experts', (done) -> require './api/experts'
  describe 'api/orders', (done) -> require './api/orders'
  describe 'api/requests', (done) -> require './api/requests'
  describe 'services/rates', (done) -> require './services/rates'
  describe 'services/request', (done) -> require './services/request'
  describe 'services/requestCalls', (done) -> require './services/requestCalls'
  describe 'mail/mailman', (done) -> require './mail/mailman'

  after (done) ->
    suiteCtx = false
    dbDestroy @, done
