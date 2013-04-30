exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##  To render all tags for admin
#############################################################################

# class exports.TagEditView extends BB.ModelSaveView
#   el: '#tagEditView'
#   tmpl: require './templates/Form'
#   viewData: ['name','short','soId','ghId']
#   events:
#     'click .save': 'save'
#     'click .cancel': -> @render new M.Skill(); false
#   initialize: ->
#   render: (model) ->
#     if model? then @model = model
#     @$el.html @tmpl @model.toJSON()
#     @
#   renderSuccess: (model, response, options) =>
#     @$('.alert-success').fadeIn(800).fadeOut(5000)
#     @collection.add model
#     @render new M.Skill()


class exports.TagRowView extends Backbone.View
  className: 'tag label'
  tmpl: require './templates/Row'
  initialize: -> @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @model.toJSON()
    @

class exports.TagsView extends Backbone.View
  el: '#tags'
  initialize: (args) ->
    @collection.on 'reset add remove filter', @render, @
  render: ->
    $list = @$el.html ''
    for m in @collection.models
      $list.append new exports.TagRowView( model: m ).render().el
    @$('.tag a').popover({})
    @


# class exports.SkillsView extends DataListView
#   el: '#skills'
#   tmpl: require './templates/Skills'
#   initialize: (args) ->
#     @$el.html @tmpl()
#     @formView = new exports.SkillFormView( model: new M.Skill(), collection: @collection ).render()
#     @collection.on 'reset add remove filter', @render, @
#   render: ->
#     $skillsList = @$('#skillsList').html ''
#     for m in @collection.models
#       $skillsList.append new exports.SkillRowView( model: m ).render().el
#     @$('.skill a').popover({})
#     @

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
    @selected = args.selected
    @$el.html @tmpl()
  saveWithMode: (e, mode) ->
    @model = new M.Tag addMode: mode
    @save e
  renderSuccess: (model, response, options) =>
    @$('input').val ''
    @selected.toggleTag model.toJSON()
    @collection.add model
    @collection.trigger 'sync'  # causes the tag form to go away
  renderError: (model, response, options) =>
    alert 'failed to add tag... is that a valid stackoverflow tag?'


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
    @listenTo @model, 'change:tags', @render
    @$auto = @$('.autocomplete').on 'input', =>
      @renderInputValid @$('.autocomplete')
      @renderInputValid @$('[name=newStackoverflow]')
  render: ->
    @$('.error-message').remove() # in case we had an error fire first
    @$('.selected').html ''
    if @model.get('tags')?
      @$('.selected').append(@tagHtml(t)) for t in @model.get('tags')
    @
  tagHtml: (t) ->
    "<span class='label label-tag'>#{t.short} <a href='#{t._id}' class='rmTag'>x</a></span>"
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
    $log 'deselect', _id
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