"""
Backbone.Validation is (should) already be available on the global scope

TODO: JK(03.16.13) consider reviewing & moving backbone-validation_bootstrap
into this class

"""

HasErrorStateView = require './HasErrorStateView'


# A view that  (1) is capable of rendering an error state
module.exports = class HasBootstrapErrorStateView extends HasErrorStateView

  constructor: (args) ->

    HasErrorStateView::constructor.apply @, arguments
    @errorSummary = @$('.alert-error')

    Backbone.Validation.unbind @
    Backbone.Validation.bind @

  renderErrorSummary: (model, errors) ->

    # Use big red alert box on server errors
    # If showAlertOnClientError = true, display on client errors also
    if @errorSummary.length > 0

      # take top level error message / description
      msg = errors.message

      # if we have other detail that cannot be
      # attributed to a specific input we append it
      if errors.data? && errors.data.other?
        msg = "#{msg}: #{errors.data.other}"

      @errorSummary.html( msg ).fadeIn()

  renderInputInvalid: (input, msg) ->

    Backbone.Validation.renderBootstrapInputInvalid input, msg

  renderInputsValid: ->

    # refresh the view so errors don't show
    Backbone.Validation.renderBootstrapInputValid @$('input')

