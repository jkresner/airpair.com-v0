BB = require 'BB'
SV = require '../../shared/Views'

Handlebars.registerPartial 'MarketingTag', require '../../shared/templates/MarketingTag'

class MarketingTagView extends BB.BadassView
  tagName: 'span'
  tmpl: require '../../shared/templates/MarketingTag'
  events:
    'click .marketingtag': 'select'
  initialize: -> @listenTo @model, 'change', @render
  render: ->
    @$el.html @tmpl @model.toJSON()
    # by putting the popover only over the text, it disappears when you hover
    # the delete button. We do this b/c .popover('destroy') is broken
    @$el.popover(selector: '[data-toggle="popover"]')
    @
  select: ->
    @selected.set '_id', @model.id, silent: true
    @selected.fetch reset: true

class exports.MarketingTagList extends BB.ModelSaveView
  el: '#marketingTagList'
  initialize: -> @listenTo @collection, 'sync', @render
  render: ->
    $list = @$el.html ''
    for model in @collection.models
      $list.append new MarketingTagView({ model, @selected }).render().el
    @

class exports.MarketingTagForm extends BB.ModelSaveView
  el: '#marketingTagForm'
  viewData: ['group', 'type', 'name', '_id']
  tmpl: require './templates/MarketingTagForm'
  events:
    'change [name="type"]': @renderGroup
    'click .save': (e) ->
      $(e.currentTarget).attr('disabled', true)
      @save(e)
  initialize: ->
    @listenTo @model, 'change', @render
    @render()
  render: ->
    @$el.html @tmpl @model.toJSON()
    @renderGroup()
    @elm('type').change @renderGroup
    @
  renderGroup: =>
    @$('#control-group').toggle @elm('type').val() is 'channel'
  renderSuccess: =>
    @$('.save').attr('disabled', false)
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.fetch reset: true
  renderError: (model, response, options) ->
    @$('.save').attr('disabled', false)
    super model, response, options


exports.MarketingTagsInputView = SV.MarketingTagsInputView
