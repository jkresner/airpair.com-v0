# require './../../test-setup'
# require './../../test-http-setup'
# docs on expect syntax                         chaijs.com/api/bdd/
# docs on using spy/fake/stub                   sinonjs.org/docs/
# docs on sinon chai syntax                     chaijs.com/plugins/sinon-chai
{_, $, $log, Backbone} = window
# hlpr = require './../helper'
# BB = require 'lib/BB'
# M = require 'scripts/request/Models'
# C = require 'scripts/request/Collections'
# V = require 'scripts/request/Views'
# data =
#   requests: require './../data/requests'
#   tags: require './../data/tags'

describe 'Request:Views RequestFormView =>', ->

  before -> $log 'Request:Views RequestFormView'

  beforeEach ->
    # hlpr.clean_setup @
    # hlpr.set_htmlfixture '<div id="requestForm"></div>'
    # @request = new M.Request()
    # @tags = new C.Tags( data,tags )
    # @viewData = model: @request, tags: @tags

  afterEach ->
    # hlpr.clean_tear_down @

  it 'validation on tags fires with no tags', ->
    # @spys.infoRender = sinon.spy V.RequestFormInfoView::, 'render'
    # view = new V.RequestFormInfoView @viewData
    # @request.clearAndSetDefaults()
    # expect(@spys.infoRender.calledOnce).to.be.true


  it 'validation error goes away when a tag is chosen', ->

  it 'validation on brief fires with brief', ->

  it 'validation on availability fires with not availability', ->


