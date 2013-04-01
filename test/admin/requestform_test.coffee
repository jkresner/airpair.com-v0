# docs on expect syntax                         chaijs.com/api/bdd/
# docs on using spy/fake/stub                   sinonjs.org/docs/
# docs on sinon chai syntax                     chaijs.com/plugins/sinon-chai
{_, $, $log, Backbone} = window
hlpr = require './../helper'
BB = require 'lib/BB'
M = require 'scripts/admin/Models'
C = require 'scripts/admin/Collections'
V = require 'scripts/admin/Views'


describe 'Admin:Views RequestFormInfoView =>', ->

  before -> $log 'Admin:Views RequestFormInfoView'

  beforeEach ->
    hlpr.clean_setup @
    hlpr.set_htmlfixture '<div id="reqInfo"></div>'
    @request = new M.Request()
    hlpr.createStub @, @request, 'skillSoIdsList', -> 'ruby-on-rails'
    @companys = new Backbone.Collection [{ _id: 1, name: "Vero" },{ _id: 2 , name: "Joe" }]
    @viewData = model: @request, companys: @companys

  afterEach ->
    hlpr.clean_tear_down @

  it 'request clearAndSetDefaults causes render', ->
    @spys.infoRender = sinon.spy V.RequestFormInfoView::, 'render'
    view = new V.RequestFormInfoView @viewData
    @request.clearAndSetDefaults()
    expect(@spys.infoRender.calledOnce).to.be.true

  it 'request set attributes causes render', ->
    @spys.infoRender = sinon.spy V.RequestFormInfoView::, 'render'
    # view = new V.RequestFormInfoView @viewData
    # @request.set 'companyId': 123123
    # expect(@spys.infoRender.calledOnce).to.be.true


describe 'Admin:Views RequestFormView =>', ->

  before -> $log 'Admin:Views RequestFormView'

  beforeEach ->
    hlpr.clean_setup @
    hlpr.set_htmlfixture '<div id="requestForm"></div>'
    @request = new Backbone.Model()
    hlpr.createStub @, @request, 'skillSoIdsList', -> 'ruby-on-rails'
    @companys = new Backbone.Collection [{ _id: 1, name: "Vero" },{ _id: 2 , name: "Joe" }]
    @devs = new Backbone.Collection()
    @requests = new Backbone.Collection()
    @viewData = model: @request, companys: @companys, devs: @devs, collection: @requests

  afterEach ->
    hlpr.clean_tear_down @


  it 'has info, suggestions & calls views', ->
    view = new V.RequestFormView @viewData
    expect(view.infoView).to.be.an.instanceof V.RequestFormInfoView
    expect(view.suggestionsView).to.be.an.instanceof V.RequestFormSuggestionsView
    expect(view.callsView).to.be.an.instanceof V.RequestFormCallsView


  it 'renders info, suggestions & calls views after model set', ->
    @spys.infoRender = sinon.spy V.RequestFormInfoView::, 'render'
    @spys.suggestionsView = sinon.spy V.RequestFormSuggestionsView::, 'render'
    @spys.callsView = sinon.spy V.RequestFormCallsView::, 'render'
    view = new V.RequestFormView @viewData
    @request.set 'companyId': 123123
    expect(@spys.infoRender.calledOnce).to.be.true
    expect(@spys.suggestionsView.calledOnce).to.be.true
    expect(@spys.callsView.calledOnce).to.be.true


  it 'doesnt save info when company not supplied', ->
    @spys.renderSuccess = sinon.spy V.RequestFormView::, 'renderSuccess'
    @spys.renderError = sinon.spy V.RequestFormView::, 'renderError'
    view = new V.RequestFormView @viewData
    @request.set 'companyId': 123123
    $log "view.$('.save').click()", view.$('.save'), V.RequestFormView::renderError
    expect(@spys.renderSuccess.calledOnce).to.be.false
    expect(@spys.renderError.calledOnce).to.be.true


  # it 'renders clean when model clearAndSetDefaults called (for new request)', ->
  #   expect(false).to.be.true


  # it 'doesnt save info when brief not supplied', ->


  #it 'renders info, suggestions & calls views after save', ->


  # it 'can add a suggestion & suggestion gets added to calls drop down', ->


  # it 'can add a call', ->


  # it 'can update call info', ->