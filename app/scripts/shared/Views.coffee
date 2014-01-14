exports = {}
BB = require './../../lib/BB'
M = require './Models'
exports.TagsInputView = require('./../tags/Views').TagsInputView
exports.MarketingTagsInputView =
  require('../marketingtags/Views').MarketingTagsInputView

Handlebars.registerPartial "DevLinks", require('./templates/DevLinks')

Handlebars.registerHelper "localDateTime", (utcDateString) ->
  # $log 'moment', moment
  day = moment utcDateString
  day.local().format("MMM DD HH:mm")

Handlebars.registerHelper "localDateTimeSeconds", (utcDateString) ->
  day = moment utcDateString
  day.local().format("MMM DD HH:mm:ss")

Handlebars.registerHelper 'markdown', (text) ->
  result = marked(text);
  new Handlebars.SafeString result


class exports.AvailabiltyInputView extends BB.BadassView
  # logging: on
  el: '#availabilityInput'
  tmpl: require './templates/AvailabilityInput'
  events:
    'click .rm': 'deselect'
  initialize: (args) ->
    @$el.append @tmpl @model.toJSON()
    @listenTo @model, 'change:availability', @render
    @$timeselect = @$('.datetimepicker')
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


class exports.ExpertView extends BB.BadassView
  tmpl: require './templates/Expert'
  initialize: (args) ->
    @listenTo @model, 'change', @render
  render: ->
    d = (_.extend @model.toJSON(), { hasNoLinks: !@model.hasLinks() } )
    @$el.html @tmpl d
    @


# ## ? not used
# class exports.DataListView extends BB.BadassView
#   events:
#     'click .edit': (e) -> @formView.render @getModelFromDataId(e)
#     'click .delete': 'destroyRemoveModel'
#     'click .detail': (e) -> false
#   getModelFromDataId: (e) ->
#     e.preventDefault()
#     id = $(e.currentTarget).data('id')
#     _.find @collection.models, (m) -> m.id is id
#   destroyRemoveModel: (e) ->
#     m = @getModelFromDataId(e)
#     m.destroy()
#     @collection.remove m

# class exports.locationInput = ($el, selector, hidden_selector) ->
#   if google? && google.maps?
#     input = $el.find selector
#     hd = $el.find hidden_selector
#     options = { types: ['(cities)'] }
#     autocomplete = new google.maps.places.Autocomplete(input.get(0), options)

    # http://stackoverflow.com/questions/12816428/how-to-fire-place-changed-event-for-google-places-auto-complete-on-enter-key
    # input.keypress (e) ->
    #   if (e.which == 13)
    #     google.maps.event.trigger(autocomplete, 'place_changed')
    #     false

    # updateInput = ->
    #   Backbone.Validation.renderBootstrapInputValid input
    #   place = autocomplete.getPlace()
    #   if ! place? || ! place.geometry
    #     # Inform the user that the place was not found and return.
    #     Backbone.Validation.renderBootstrapInputInvalid input, 'Place not found'
    #   else
    #     hd.val place.formatted_address

    # set the input string or error when place selected
    # google.maps.event.addListener autocomplete, 'place_changed', updateInput

    # if user changes location_id textbox value after google place_changed was successful
    # input.on 'change', -> hd.val ''


module.exports = exports
