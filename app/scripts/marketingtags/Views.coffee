BB = require './../../lib/BB'

VIEW_DATA = [ 'group', 'type', 'name']
Handlebars.registerPartial 'MarketingTag', require './templates/MarketingTag'

class exports.MarketingTagForm extends BB.ModelSaveView
  el: '#marketingTagForm'
  viewData: VIEW_DATA
  tmpl: require './templates/MarketingTagList'
  events:
    'click .save': 'addTag'
    'click .delete': 'deleteTag'
  initialize: ->
    @listenTo @collection, 'sync', @render
    # by putting the popover only over the text, it disappears when you hover
    # the delete button. We do this b/c .popover('destroy') is broken
    @$el.popover(selector: '[data-toggle="popover"]')
  render: ->
    marketingTags = @collection.toJSON().map (t) ->
      t.popover = true
      t.removable = true
      t
    @$('#marketingTagList').html @tmpl { marketingTags }
    @
  addTag: (e) ->
    @model.unset('_id')
    @save e
  deleteTag: (e) ->
    e.preventDefault()
    id = $(e.target).data('id')
    model = _.find @collection.models, (m) -> m.get('_id') == id
    model.destroy()
    @collection.fetch()
  renderSuccess: ->
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.fetch()

class exports.MarketingTagsInputView extends BB.HasBootstrapErrorStateView
  el: '#marketingTagsInput'
  tmpl: require './templates/Input'
  tmplResult: require './templates/TypeAheadResult'
  tmplTag: require './templates/MarketingTag'
  events:
    'click .delete': 'deselect'
  initialize: (args) ->
    @$el.append @tmpl @model.toJSON()
    @listenTo @collection, 'sync', @initTypehead
    @listenTo @model, 'change:marketingTags', @render
    # we need this because many requests have .marketingTags == undefined, and
    # so the change:marketingTags event does not trigger.
    @listenTo @model, 'change', @render
    @$auto = @$('.autocomplete').on 'input', =>
      @renderInputValid @$('.autocomplete')
    @$el.popover(selector: '[data-toggle="popover"]')
  render: ->
    @$('.selected').html ''
    if @model.get('marketingTags')?
      @$('.selected').append(@tagHtml(t)) for t in @model.get('marketingTags')
    @
  tagHtml: (t) ->
    t.removable = true
    t.popover = true
    @tmplTag(t)
  _joined: (t) ->
    values = _.values _.pick(t, VIEW_DATA)
    values.join(' ')
  initTypehead: =>
    @cleanTypehead().val('').show()
    @$auto.typeahead(
      header: '<header><strong>Marketing Tags</strong></header>'
      noresultsHtml: 'No results'
      name: 'collection' + new Date().getTime()
      valueKey: 'joined'
      template: @tmplResult
      local: @collection.toJSON().map (t) =>
        t.joined = 'all ' + t.name.toLowerCase()
        t
    ).on('typeahead:selected', @select)
    @
  select: (e, data) =>
    if e then e.preventDefault()
    @_toggleMarketingTag data
    @$auto.val ''
  deselect: (e) =>
    e.preventDefault()
    _id = $(e.target).data 'id'
    match = _.find @collection.models, (m) -> m.get('_id') == _id
    @_toggleMarketingTag match.toJSON()
  _toggleMarketingTag: (value) ->
    tag = _.pick value, VIEW_DATA.concat '_id'
    equalById = (m) -> m._id == value._id
    @model.toggleAttrSublistElement 'marketingTags', tag, equalById
  cleanTypehead: ->
    @$auto.typeahead('destroy').off 'typeahead:selected'
  getViewData: ->
    @model.get 'marketingTags'
