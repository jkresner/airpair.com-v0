exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##  To render all tags for admin
#############################################################################

# class exports.TagRowView extends Backbone.View
#   className: 'tag label'
#   tmpl: require './templates/Row'
#   initialize: -> @model.on 'change', @render, @
#   render: ->
#     @$el.html @tmpl @model.toJSON()
#     @

# class exports.TagsView extends Backbone.View
#   el: '#tags'
#   initialize: (args) ->
#     @collection.on 'reset add remove filter', @render, @
#   render: ->
#     $tagList = @$el.html ''
#     for m in @collection.models
#       $tagList.append new exports.TagRowView( model: m ).render().el
#     @$('.tag a').popover({})
#     @

#############################################################################
##  Autocomplete and add new tag views
#############################################################################

class exports.TagNewForm extends BB.ModelSaveView
  logging: on
  el: '#tagNewForm'
  tmpl: require './templates/NewForm'
  viewData: ['nameStackoverflow','nameGithub']
  events:
    'click .save-so': (e) -> @saveWithMode e, 'stackoverflow'
    'click .save-gh': (e) -> @saveWithMode e, 'github'
  initialize: (args) ->
    @selected = args.selected
    @$el.html @tmpl()
  saveWithMode: (e, mode) ->
    @model = new M.Tag addMode: mode
    @save e
  renderSuccess: (model, response, options) =>
    @$('input').val ''
    @collection.add model
    @selected.toggleTag model.toJSON()


class exports.TagsInputView extends BB.BadassView
  logging: on
  el: '#tagsInput'
  tmpl: require './templates/Input'
  tmplAutoResult:  require './templates/AutocompleteResult'
  events:
    'click .rm': 'deselect'
    'click .new': 'newTag'
  initialize: (args) ->
    @$el.append @tmpl @model.toJSON()
    @newForm = new exports.TagNewForm selected: @model, collection: @collection
    @listenTo @collection, 'sync', @initTypehead
    @listenTo @model, 'change', @render
    @$auto = @$('.autocomplete')
    @$auto.on 'blur', => @$auto.val ''   # makes it so no value off focus
  render: ->
    @$('.selected').html ''
    @$('.selected').append(@tagHtml(t)) for t in @model.get('tags')
    @
  tagHtml: (t) ->
    "<span class='label label-warning'>#{t.short} <a href='#{t._id}' class='rm'>x</a></span>"
  initTypehead: ->
    #$log 'initTypehead', @collection.toJSON()
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


module.exports = exports