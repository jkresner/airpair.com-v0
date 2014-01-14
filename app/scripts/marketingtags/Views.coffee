BB = require './../../lib/BB'

VIEW_DATA = [ 'group', 'type', 'name']

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
    @$('#marketingTagList').html @tmpl { marketingtags: @collection.toJSON() }
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

# TODO between the views of a different requests, clear thyself
class exports.MarketingTagsInputView extends BB.HasBootstrapErrorStateView
  el: '#marketingTagsInput'
  tmpl: require './templates/Input'
  tmplResult: require './templates/TypeAheadResult'
  events:
    'click .rmTag': 'deselect'
  initialize: (args) ->
    @$el.append @tmpl @model.toJSON()
    @listenTo @collection, 'sync', @initTypehead
    @listenTo @model, 'change:marketingTags', @render
    @$auto = @$('.autocomplete').on 'input', =>
      @renderInputValid @$('.autocomplete')
  render: ->
    @$('.error-message').remove() # in case we had an error fire first
    @$('.selected').html ''
    if @model.get('marketingTags')?
      @$('.selected').append(@tagHtml(t)) for t in @model.get('marketingTags')
    @
  tagHtml: (t) ->
    "<span class='label label-tag'>#{@_joined(t)} <a href='#{t._id}' title='#{t.name}' class='rmTag'>x</a></span>"
  _joined: (t) ->
    values = _.values _.pick(t, VIEW_DATA)
    values.join(' ')
  initTypehead: =>
    @cleanTypehead().val('').show()
    @$auto.typeahead(
      header: "<header><center><b>#{VIEW_DATA.join(' - ')}<b></center></header>"
      noresultsHtml: 'No results'
      name: 'collection' + new Date().getTime()
      valueKey: 'joined'
      template: @tmplResult
      local: @collection.toJSON().map (t) =>
        t.joined = @_joined t
        t
    ).on('typeahead:selected', @select)
    @
  select: (e, data) =>
    if e then e.preventDefault()
    @_toggleMarketingTag data
    @$auto.val ''
  deselect: (e) =>
    e.preventDefault()
    _id = $(e.currentTarget).attr 'href'
    match = _.find @collection.models, (m) -> m.get('_id') == _id
    @_toggleMarketingTag match.toJSON()
  # TODO this should go in the model, except that it's nice to reuse VIEW_DATA
  _toggleMarketingTag: (value) ->
    tag = _.pick value, VIEW_DATA.concat '_id'
    equalById = (m) -> m._id == value._id
    @model.toggleAttrSublistElement 'marketingTags', tag, equalById
  cleanTypehead: ->
    @$auto.typeahead('destroy').off 'typeahead:selected'
  getViewData: ->
    @model.get 'marketingTags'
