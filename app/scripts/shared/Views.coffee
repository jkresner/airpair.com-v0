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