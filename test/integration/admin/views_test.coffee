# # docs on expect syntax                         chaijs.com/api/bdd/
# # docs on using spy/fake/stub                   sinonjs.org/docs/
# # docs on sinon chai syntax                     chaijs.com/plugins/sinon-chai
# {_, $, $log, Backbone} = window
# hlpr = require './../../test-ui-helper'
# BB = require 'lib/BB'
# M = require 'scripts/admin/Models'
# C = require 'scripts/admin/Collections'
# V = require 'scripts/admin/Views'
# T = {}

# class T.MockRequest extends Backbone.Model
#   defaults: { suggested: [], calls: [] }
#   createdDateString: -> 'Today'


# class T.MockRequests extends Backbone.Collection
#   model: T.MockRequest


# describe 'Admin:Views =>', ->

#   describe 'RequestsViews =>', ->

#     before ->
#       $log 'Admin:Views RequestsView'

#     beforeEach ->
#       hlpr.clean_setup @
#       hlpr.set_htmlfixture '<div id="requests"></div>'
#       @requests = new T.MockRequests()
#       @requestsData = [{ _id: 1, name: "Vero" },{ _id: 2 , name: "Joe" }]

#     afterEach ->
#       hlpr.clean_tear_down @

#     it 'renders after collection reset', ->
#       @spys.render = sinon.spy V.RequestsView::, 'render'
#       view = new V.RequestsView collection: @requests
#       @requests.reset @requestsData
#       expect(@spys.render.calledOnce).to.be.true
