BB = require './../../lib/BB'

class exports.MarketingTagForm extends BB.ModelSaveView
  logging: on
  el: '#marketingTagForm'
  viewData: [ 'name', 'type', 'group' ]
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
#
# TODO adding a source to a request
#
# class exports.TagNewForm extends BB.ModelSaveView
#   el: '#tagNewForm'
#   tmpl: require './templates/NewForm'
#   viewData: ['nameStackoverflow','nameGithub']
#   events:
#     'click .save-so': 'save'
#     'click .cancel': (e) -> @collection.trigger 'sync'; false
#   initialize: (args) ->
#     @model = new M.Tag()
#     @selected = args.selected
#     @$el.html @tmpl()
#     @$stackName = @elm("nameStackoverflow")
#     @listenTo @$stackName, 'change', => @renderInputsValid()
#   renderSuccess: (model, response, options) =>
#     @$('input').val ''
#     @selected.toggleTag model.toJSON()
#     @collection.add model
#     @collection.trigger 'sync'  # causes the tag form to go away
#   # renderError: (model, response, options) =>
#     # @renderInputInvalid @$stackName, 'failed to add tag... is that a valid stackoverflow tag?'
