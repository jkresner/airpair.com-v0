BB = require 'BB'

class MarketingTagsInputView extends BB.HasBootstrapErrorStateView
  el: '#marketingTagsInput'
  tmpl: require './templates/TagInput'
  tmplResult: require './templates/TagAutocompleteResult'
  tmplTag: require './templates/MarketingTag'
  events:
    'click .delete': 'deselect'
  initialize: (args) ->
    # @$el.append @tmpl @model.toJSON()
    # @listenTo @collection, 'sync', @initTypehead
    # @listenTo @model, 'change:_id', -> @$auto.val '' # clears it across requests
    # @listenTo @model, 'change:marketingTags', @render
    # @$auto = @$('.autocomplete').on 'input', =>
    #   @renderInputValid @$('.autocomplete')
    # @$el.popover(selector: '[data-toggle="popover"]')
  render: ->
    @$('.selected').html ''
    if @model.get('marketingTags')?
      @$('.selected').append(@tmplTag(t)) for t in @model.get('marketingTags')
    @
  initTypehead: =>
    # @cleanTypehead().val('').show()
    # @$auto.typeahead(
    #   header: '<header><strong>Marketing Tags</strong></header>'
    #   noresultsHtml: 'No results'
    #   name: 'collection' + new Date().getTime()
    #   valueKey: 'name'
    #   template: @tmplResult
    #   local: @collection.toJSON().map (t) =>
    #     t.name = t.name.toLowerCase()
    #     t
    # ).on('typeahead:selected', @select)
    @
  select: (e, data) =>
    if e then e.preventDefault()
    @_toggleMarketingTag data
    @$auto.val ''
  _toggleMarketingTag: (value) ->
    tag = _.pick value, VIEW_DATA
    equalById = (m) -> m._id == value._id
    @model.toggleAttrSublistElement 'marketingTags', tag, equalById
  deselect: (e) =>
    e.preventDefault()
    _id = $(e.target).data 'id'
    without = _.filter @model.get('marketingTags'), (t) -> t._id != _id
    @model.set('marketingTags', without)
  cleanTypehead: ->
    @$auto.typeahead('destroy').off 'typeahead:selected'
  getViewData: ->
    @model.get 'marketingTags'

module.exports = MarketingTagsInputView
