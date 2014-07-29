exports = {}
BB      = require 'BB'
M       = require './Models'
SV      = require '../../shared/Views'

Handlebars.registerPartial "Links", require('./templates/Links')

#############################################################################
##  To render all experts for admin
#############################################################################

class exports.ExpertRowView extends BB.BadassView
  tagName: 'tr'
  className: 'expert'
  tmpl: require './templates/Row'
  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', => @$el.remove()
  render: ->
    @$el.html @tmpl _.extend @model.toJSON(), { hasLinks: @model.hasLinks() }
    @


class exports.ExpertsView extends Backbone.View
  el: '#experts'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    $list = @$('tbody').html ''
    for m in @collection.models
     $list.append new exports.ExpertRowView( model: m ).render().el
    @$('.count').html @collection.models.length
    @


class exports.BookMeView extends BB.ModelSaveView
  el: '#bookMe'
  tmpl: require './templates/BookMe'
  viewData: ['rate', 'rake', 'urlSlug', 'urlBitly', 'urlBlog', 'noIndex']
  events:
    'change .enabled': 'setEnabled'
  initialize: ->
    @model.once 'change', =>
      @render()
      @listenTo @model, 'change:bookMe', @render
  render: ->
    d = @model.get('bookMe')
    if !d?
      @$el.html @tmpl {}
    else
      @$el.html @tmpl d
      c = @model.get('bookMe').coupons
      if c && c[0] then @elm('code1').val(c[0].code); @elm('rate1').val(c[0].rate)
      if c && c[1] then @elm('code2').val(c[1].code); @elm('rate2').val(c[1].rate)
    @
  setEnabled: (e) ->
    bm =_.clone @model.get('bookMe')
    if !bm?
      @model.set 'bookMe', { enabled: true }
    else
      bm.enabled = @elm('enabled').val() == 'true'
      @model.set 'bookMe', bm
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.enabled = @elm('enabled').val() == 'true'
    d.coupons = []
    if @elm('code1').val() then d.coupons.push { code: @elm('code1').val(), rate: @elm('rate1').val() }
    if @elm('code2').val() then d.coupons.push { code: @elm('code2').val(), rate: @elm('rate2').val() }
    d

class exports.TagSubscriptionsView extends BB.ModelSaveView
  el: '#tagSubscriptions'
  tmpl: require './templates/TagSubscriptions'
  events:
    'change .subscription': 'toggleSubscription'
  initialize: ->
    @model.once 'change', =>
      @render()
      @listenTo @model, 'change:tags', @render
  render: ->
    @$el.html @tmpl @model.toJSON()
    for tag in @model.get('tags')
      for type in ['auto','custom']
        for level in (tag.subscription?[type] || [])
          hash = "#{tag._id}_#{level}_#{type}"
          @$("[data-hash='#{hash}']").attr('checked','checked')
    @
  updateSubscriptions: (tags) ->
    for tag in tags
      $log 'tag', tag
      tag.subscription = auto: [], custom: []
      for level in ['beginner','intermediate','advanced']
        tag.subscription['auto'].push level if @$("[data-hash='#{tag._id}_#{level}_auto']").is(':checked')
        tag.subscription['custom'].push level if @$("[data-hash='#{tag._id}_#{level}_custom']").is(':checked')
    tags


class exports.ExpertView extends BB.ModelSaveView
  el: '#edit'
  tmpl: require './templates/Expert'
  tmplLinks: require './templates/Links'
  viewData: ['name', 'email', 'gmail', 'pic', 'homepage', 'skills', 'rate']
  events:
    'click .save': 'save'
    'click .deleteExpert': 'destroy'
    'click .btn-gravatar': 'setGravatar'
  initialize: ->
    @$el.html @tmpl {}
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @bookMe = new exports.BookMeView model: @model
    @tagSubscriptions = new exports.TagSubscriptionsView model: @model
    @listenTo @model, 'change', @render
  render: (model) ->
    @setValsFromModel ['name', 'email', 'gmail', 'pic', 'homepage', 'brief', 'hours']
    @$("img.pic").prop 'src', @model.get('pic')
    @$(":radio[value=#{@model.get('rate')}]").prop('checked',true).click()
    @$(":radio[value=#{@model.get('status')}]").prop('checked',true).click()
    @$(".links").html @tmplLinks @model.toJSON()
    @$(".btn-gravatar").toggle @model.get('gh')?
    @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    m = @collection.findWhere(_id: model.id)
    if m
      m.set model.attributes
      m.trigger 'change' # for the expert row to re-render
  getViewData: ->
    name: @elm('name').val()
    pic: @elm('pic').val()
    homepage: @elm('homepage').val()
    brief: @elm('brief').val()
    hours: @elm('hours').val()
    rate: @$("[name='rate']:checked").val()
    status: @$("[name='status']:checked").val()
    tags: @tagSubscriptions.updateSubscriptions( @tagsInput.getViewData() )
    bookMe: @bookMe.getViewData()
  destroy: ->
    m = @collection.findWhere(_id: @model.id)
    m.destroy()
    router.navTo '#list'
  setGravatar: (e)->
    @model.set 'pic', "//0.gravatar.com/avatar/#{@model.get('gh').gravatar_id}"
    false

module.exports = exports
