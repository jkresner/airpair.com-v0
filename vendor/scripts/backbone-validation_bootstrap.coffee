# These were refactored out so they could be used without having to tie into backbone validation callback

Backbone.Validation.renderBootstrapInputInvalid = (control, error) ->
  group = control.parents(".control-group")
  group.addClass("error")

  # $log 'renderBootstrapInputInvalid', control, error

  if control.data("error-style") == "tooltip"
    position = control.data("tooltip-position") || "right"
    control.tooltip
      placement: position
      trigger: "manual"
      title: error
    control.tooltip "show"
  else if control.data("error-style") == "inline"
    if group.find(".help-inline").length == 0
      group.find(".controls").append("<span class=\"help-inline error-message\"></span>")
    target = group.find(".help-inline")
    target.text(error)
  else
    if group.find(".help-block").length == 0
      group.find(".controls").append("<p class=\"help-block error-message\"></p>")
    target = group.find(".help-block")
    target.text(error)


Backbone.Validation.renderBootstrapInputValid = (control) ->
  group = control.parents(".control-group")
  group.removeClass("error")

  if control.data("error-style") == "tooltip"
    # CAUTION: calling tooltip("hide") on an uninitialized tooltip
    # causes bootstraps tooltips to crash somehow...
    control.tooltip "hide" if control.data("tooltip")
  else if control.data("error-style") == "inline"
    group.find(".help-inline.error-message").remove()
  else
    group.find(".help-block.error-message").remove()


# https://gist.github.com/2909552
# Ties Backbone.Validation Plugin to standard Bootstrap by injecting input level error messages into the view
_.extend Backbone.Validation.callbacks,

  valid: (view, attr, selector) ->
    control = view.$('[' + selector + '=' + attr + ']')
    Backbone.Validation.renderBootstrapInputValid(control)

  invalid: (view, attr, error, selector) ->
    control = view.$('[' + selector + '=' + attr + ']')
    Backbone.Validation.renderBootstrapInputInvalid(control, error)