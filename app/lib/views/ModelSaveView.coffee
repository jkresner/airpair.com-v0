HasBootstrapErrorStateView = require './HasBootstrapErrorStateView'

# A view that   (1) knows how to save a model & hook in Backbone.Validation
#               (2) knows how to get data from the view for saving the model via 'viewdata()'
#               (3) is capable of rendering an success state
#               (4) put the view back into default state if the user tries to save without changes to the model
exports = class ModelSaveView

  # change this guy in the class definition to use a different
  # error rendering mechanism
  ErrorStateViewType:   HasBootstrapErrorStateView

  async: on

  constructor: (args) ->
    @ErrorStateViewType::constructor.apply @, arguments

  initialize: ->
    throw Error 'must inherit ModelSaveView & implement initialize'

  save: (e) ->
    if e? then e.preventDefault()

    newattrs = @viewData()

    if @logging
      $log 'ModelSaveView.save', 'old:',@model.toJSON(), 'new:',newattrs, 'changes:', @model.changedAttributes newattrs

    # Remove any existing error state before we try save again
    @renderInputsValid()

    options = success: @renderSuccess, _error: @rendererror, wait: !@async
    @model.save newattrs, options

  # By default renderSuccess looks for a bootstrap alert-success element
  # override in inheriting classes for custom behavior
  renderSuccess: (model, response, options) =>

    if @logging
      $log 'ModelSaveView.renderSuccess', @, model, response, options

    if @$('.alert-success').length > 0
      @$('.alert-success').fadeIn(800).fadeOut(5000)

  viewData: ->
    throw Error 'override viewData function in inheriting view classes'

  # assumes name (NOT ID!) of an input matches the name of an attribute & grabs the vals associated w specified atrrs
  getValsFromInputs: (attrs) ->
    obj = {}
    obj[attr] = @$('[name="'+attr+'"]').val() for attr in attrs
    obj