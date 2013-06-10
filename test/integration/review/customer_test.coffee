{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'
M = require '/scripts/review/Models'
C = require '/scripts/review/Collections'
V = require '/scripts/review/Views'

data =
  users: require './../../data/users'
  requests: require './../../data/requests'


fixture = "<div id='detail' class='route'><div id='request'></div></div>"


describe "Review page: customer", ->

  before (done) ->
    hlpr.set_initApp '/scripts/review/Router'
    hlpr.setSession 'jk', =>
      $.post('/api/requests',data.requests[7]).done (data) =>
        @rId = data._id
        hlpr.setSession 'anon', done

  beforeEach ->
    hlpr.clean_setup @, fixture
    initApp session: { authenticated: false }
    @router = window.router

  afterEach ->
    hlpr.clean_tear_down @


  # it "when reviewing as customer and expert hasn't replied", (done) ->
  #   seeWaitingForExpertReply = true
  #   expect(seeWaitingForExpertReply).to.equal true
  #   done()


  # it "when reviewing as customer and expert has replied", (done) ->
  #   seeReplyCommentsByExpert = true
  #   expect(seeReplyCommentsByExpert).to.equal true
  #   done()
