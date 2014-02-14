BB = require './../../lib/BB'

VIEW_DATA = [ 'group', 'type', 'name']
Handlebars.registerPartial 'MarketingTag', require './templates/MarketingTag'

class exports.MarketingTagList extends BB.ModelSaveView
  el: '#marketingTagList'
  tmpl: require './templates/MarketingTagList'
  events:
    'click .marketingtag': 'select'
  initialize: ->
    @listenTo @collection, 'sync', @render
    # by putting the popover only over the text, it disappears when you hover
    # the delete button. We do this b/c .popover('destroy') is broken
    @$el.popover(selector: '[data-toggle="popover"]')
  render: ->
    @$el.html @tmpl { marketingTags: @collection.toJSON() }
    @
  select: (e) ->
    id = $(e.currentTarget).data('id')
    if !id then return
    @selected.set '_id', id, silent: true
    @selected.fetch reset: true

class exports.MarketingTagForm extends BB.ModelSaveView
  el: '#marketingTagForm'
  viewData: VIEW_DATA
  tmpl: require './templates/MarketingTagList'
  events:
    'click .save': 'addTag'
    # 'click .delete': 'deleteTag'
  initialize: ->
  render: ->
    @
  addTag: (e) ->
    @model.unset('_id')
    @save e
  # deleteTag: (e) ->
  #   e.preventDefault()
  #   id = $(e.target).data('id')
  #   model = _.find @collection.models, (m) -> m.get('_id') == id
  #   model.destroy()
  #   @collection.fetch()
  renderSuccess: ->
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.fetch reset: true

class exports.MarketingTagEditForm extends BB.ModelSaveView
  el: '#marketingTagEditForm'
  viewData: VIEW_DATA
  tmpl: require './templates/MarketingTagList'
  events:
    'click .save': (e) ->
      $(e.currentTarget).text('Patience young padawan').attr('disabled', true)
      @save(e)
  initialize: ->
    @listenTo @model, 'sync', @render
  render: ->
    @setValsFromModel @viewData.concat('_id')
    @
  renderSuccess: =>
    @$('.save').attr('disabled', false).text('Save Edits')
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.fetch reset: true
  renderError: (model, response, options) ->
    @$('.save').attr('disabled', false).text('Save Edits')
    super model, response, options

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
    @listenTo @model, 'change:_id', -> @$auto.val '' # clears it across requests
    @listenTo @model, 'change:marketingTags', @render
    @$auto = @$('.autocomplete').on 'input', =>
      @renderInputValid @$('.autocomplete')
    @$el.popover(selector: '[data-toggle="popover"]')
  render: ->
    @$('.selected').html ''
    if @model.get('marketingTags')?
      @$('.selected').append(@tmplTag(t)) for t in @model.get('marketingTags')
    @
  initTypehead: =>
    @cleanTypehead().val('').show()
    @$auto.typeahead(
      header: '<header><strong>Marketing Tags</strong></header>'
      noresultsHtml: 'No results'
      name: 'collection' + new Date().getTime()
      valueKey: 'name'
      template: @tmplResult
      local: @collection.toJSON().map (t) =>
        t.name = t.name.toLowerCase()
        t
    ).on('typeahead:selected', @select)
    @
  select: (e, data) =>
    if e then e.preventDefault()
    @_toggleMarketingTag data
    @$auto.val ''
  _toggleMarketingTag: (value) ->
    tag = _.pick value, VIEW_DATA.concat '_id'
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
