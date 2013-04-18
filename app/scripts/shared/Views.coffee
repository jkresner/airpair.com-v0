exports = {}
BB = require './../../lib/BB'
M = require './Models'
TagViews = require './../tags/Views'


exports.TagsInputView = TagViews.TagsInputView


class exports.AvailabiltyInputView extends BB.BadassView
  logging: on
  el: '#availabilityInput'
  tmpl: require './templates/AvailabilityInput'
  events:
    'click .rm': 'deselect'
  initialize: (args) ->
    @$el.append @tmpl @model.toJSON()
    # @listenTo @model, 'change:availability', @render
    @$timeselect = @$('.timeselect')
    @$timeselect.datetimepicker( minuteStep: 30, autoclose: true )
    @$timeselect.on 'dateChanged', @select
    @$timeselect.on 'blur', => @$timeselect.val ''   # so no value off focus
  render: ->
    @$('div').html ''
    if @model.get('availability')?
      @$('div').append(d) for d in @model.get 'availability'
    @
  select: (e) =>
    # $log 'addAvailability', e
    # comes back from the datetimepicker event handler
    # !! todo, check for duplicates
    @model.toggleAvailability e.date
  deselect: (e) =>
    e.preventDefault()
    toRemove = $(e.currentTarget).data 'val'
    @model.toggleAvailability toRemove
  getViewData: ->
    if !@model.get('availability')? then undefined else @model.get 'availability'

module.exports = exports