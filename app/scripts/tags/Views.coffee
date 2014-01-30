exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##  To render all tags for admin
#############################################################################

class exports.TagEditView extends BB.ModelSaveView
  tmpl: require './templates/TagEdit'
  viewData: ['name','short','desc','tokens']
  events:
    'click .save': 'save'
    'click .cancel': -> @remove()
  initialize: ->
  render: ->
    @$el.html @tmpl @model.toJSON()
    @
  renderSuccess: (model,resp,options) =>
    @remove()


class exports.TagRowView extends BB.BadassView
  className: 'tag label'
  tmpl: require './templates/Row'
  events:
    'click a.edit': 'showTagDetail'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    @$el.html @tmpl @model.toJSON()
    @
  showTagDetail: (e) ->
    #e.preventDefault()
    @$el.append new exports.TagEditView(model: @model).render().el
    false

class exports.TagsView extends BB.BadassView
  el: '#tags'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    @$el.html ''
    for m in @collection.models
      @$el.append new exports.TagRowView( model: m ).render().el
    @$('.tag a').popover({})
    @


#############################################################################
##  Autocomplete and add new tag views
#############################################################################

class exports.TagNewForm extends BB.ModelSaveView
  el: '#tagNewForm'
  tmpl: require './templates/NewForm'
  viewData: ['nameStackoverflow','nameGithub']
  events:
    'click .save-so': (e) -> @saveWithMode e, 'stackoverflow'
    'click .save-gh': (e) -> @saveWithMode e, 'github'
    'click .cancel': (e) -> @collection.trigger 'sync'; false
  initialize: (args) ->
    @model = new M.Tag()
    @selected = args.selected
    @$el.html @tmpl()
    @$stackName = @elm("nameStackoverflow")
    @listenTo @$stackName, 'change', => @renderInputsValid()
  saveWithMode: (e, mode) ->
    @model.clear()
    @model.set addMode: mode
    @save e
    false
  renderSuccess: (model, response, options) =>
    @$('input').val ''
    @selected.toggleTag model.toJSON()
    @collection.add model
    @collection.trigger 'sync'  # causes the tag form to go away
  renderError: (model, response, options) =>
    @renderInputInvalid @$stackName, 'failed to add tag... is that a valid stackoverflow tag?'


class exports.TagsInputView extends BB.HasBootstrapErrorStateView
  el: '#tagsInput'
  tmpl: require './templates/Input'
  tmplAutoResult:  require './templates/AutocompleteResult'
  events:
    'click .rmTag': 'deselect'
    'click .new': 'newTag'
  initialize: (args) ->
    @$el.append @tmpl @model.toJSON()
    @newForm = new exports.TagNewForm selected: @model, collection: @collection
    @listenTo @collection, 'sync', @initTypehead
    @listenTo @model, 'change:_id', -> @$auto.val '' # clears it across requests
    @listenTo @model, 'change:tags', @render
    @$auto = @$('.autocomplete').on 'input', =>
      @renderInputValid @$('.autocomplete')
      @renderInputValid @elm('newStackoverflow')
  render: ->
    @$('.error-message').remove() # in case we had an error fire first
    @$('.selected').html ''
    if @model.get('tags')?
      @$('.selected').append(@tagHtml(t)) for t in @model.get('tags')
    @
  tagHtml: (t) ->
    "<span class='label label-tag'>#{t.short} <a href='#{t._id}' title='#{t.name}' class='rmTag'>x</a></span>"
  initTypehead: ->
    # $log 'initTypehead'#, @collection.toJSON()
    @newForm.$el.hide()
    @cleanTypehead().val('').show()
    @$auto.typeahead(
      header: '<header>Tags in our database</header>'
      noresultsHtml: 'No results... <a href="#" class="new"><b>add one</b></a>'
      name: 'collection' + new Date().getTime()
      valueKey: 'short'
      template: @tmplAutoResult
      local: @collection.toJSON()
    ).on('typeahead:selected', @select)
    #@$auto.on 'blur', => @$auto.val ''   # makes it so no value off focus
    @
  select: (e, data) =>
    if e? then e.preventDefault()
    @model.toggleTag data
    @$auto.val ''
  deselect: (e) =>
    e.preventDefault()
    _id = $(e.currentTarget).attr 'href'
    match = _.find @collection.models, (m) -> m.get('_id') == _id
    @model.toggleTag match.toJSON()
  newTag: (e) =>
    @cleanTypehead().hide()
    @newForm.$el.show()
    @newForm.$('input').val @$('.autocomplete').val()
  cleanTypehead: ->
    @$auto.typeahead('destroy').off 'typeahead:selected'
  getViewData: ->
    if !@model.get('tags')? then undefined else @model.get 'tags'

module.exports = exports
