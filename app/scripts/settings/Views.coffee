exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##
#############################################################################

class exports.PaymentSettingsView extends Backbone.View
  className: 'tag label'
  tmpl: require './templates/PaymentSettings'
  initialize: -> @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @model.toJSON()
    @


module.exports = exports