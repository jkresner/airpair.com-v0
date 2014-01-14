BB = require './../../lib/BB'

VIEW_DATA = [ 'group', 'type', 'name']

class exports.MarketingTagForm extends BB.ModelSaveView
  logging: on
  el: '#marketingTagForm'
  viewData: VIEW_DATA
  tmpl: require './templates/MarketingTagList'
  events:
    'click .save': 'save'
  initialize: ->
    @listenTo @collection, 'sync', @render
  render: ->
    @$('#marketingTagList').html @tmpl { marketingtags: @collection.toJSON() }
  renderSuccess: ->
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.fetch()

class exports.MarketingTagsInputView extends BB.HasBootstrapErrorStateView
  logging: on
  el: '#marketingTagsInput'
  tmpl: require './templates/Input'
  tmplResult:  require './templates/TypeAheadResult'
  events:
    'click .rmTag': 'deselect'
  initialize: (args) ->
    @$el.append @tmpl @model.toJSON()
    @listenTo @collection, 'sync', @initTypehead
    @listenTo @model, 'change:marketingTags', @render
    @$auto = @$('.autocomplete').on 'input', =>
      @renderInputValid @$('.autocomplete')
      @renderInputValid @elm('newStackoverflow')
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
  initTypehead: ->
    $log 'initTypehead'#, @collection.toJSON()
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
    #@$auto.on 'blur', => @$auto.val ''   # makes it so no value off focus
    @
  select: (e, data) =>
    if e then e.preventDefault()
    @_toggleMarketingTag data
    @$auto.val ''
  deselect: (e) =>
    e.preventDefault()
    _id = $(e.currentTarget).attr 'href'
    #$log 'deselect', _id
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

#
# TODO adding a source to a request
#
# class exports.MarketingTagPicker extends BB.ModelSaveView
#   el: '#marketingTagPicker'
#   tmpl: require './templates/TypeAheadResult' # renders dropdown
#   initialize: (args) ->
#     # ugghg

#     @listenTo @collection, 'sync', @makeTypeAhead
#   makeTypeAhead: ->
#     @$el.typeahead(
#       header: '<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;group - type - name</b>'
#       noresultsHtml: 'No results'
#       name: 'collection' + new Date().getTime()
#       valueKey: 'joined'
#       template: @tmplResult
#       local: @collection.toJSON().map (t) ->
#         {group, type, name} = t
#         t.joined = [group, type, name].join(' ')
#         t
#       minLength: -1
#     )
#   getSelectedTag: ->
#     [group, type, name] = @$el.val().split(' ')
#     {group, type, name}
