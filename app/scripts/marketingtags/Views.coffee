BB = require './../../lib/BB'

class exports.MarketingTagForm extends BB.ModelSaveView
  logging: on
  el: '#marketingTagForm'
  viewData: [ 'name', 'type', 'group', 'usage']
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
class exports.MarketingTagPicker extends BB.ModelSaveView
  el: '#marketingTagPicker'
  tmpl: require './templates/TypeAheadResult' # renders dropdown
  initialize: (args) ->
    # ugghg

    @listenTo @collection, 'sync', @makeTypeAhead
  makeTypeAhead: ->
    @$el.typeahead(
      header: '<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;group - type - name</b>'
      noresultsHtml: 'No results'
      name: 'collection' + new Date().getTime()
      valueKey: 'joined'
      template: @tmplResult
      local: @collection.toJSON().map (t) ->
        {group, type, name} = t
        t.joined = [group, type, name].join(' ')
        t
      minLength: -1
    )
  getSelectedTag: ->
    [group, type, name] = @$el.val().split(' ')
    {group, type, name}
