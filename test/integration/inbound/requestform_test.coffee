{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'
M = require '/scripts/inbound/Models'
C = require '/scripts/inbound/Collections'
V = require '/scripts/inbound/Views'

data =
  users: require './../../data/users'
  requests: require './../../data/requests'


fixture = "<div></div>"


describe "Inbound: RequestView", ->

  before (done) ->
    hlpr.set_initApp '/scripts/inbound/Router'
    done()
  afterEach -> hlpr.clean_tear_down @
  beforeEach ->
    hlpr.clean_setup @, fixture


  it 'request view does not save mail templates & tags string', (done) ->
    expect(false).to.be.true


  it 'request object had reasonable data in events objects ...', (done) ->
    expect(false).to.be.true