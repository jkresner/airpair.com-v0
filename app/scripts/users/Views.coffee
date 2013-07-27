exports = {}
BB = require './../../lib/BB'
M = require './Models'
Shared = require './../shared/Views'

#############################################################################
##  To render all users for admin
#############################################################################

class exports.UserRowView extends BB.BadassView
  tagName: 'tr'
  className: 'user'
  tmpl: require './templates/Row'
  events: { 'click .deleteUser': 'deleteUser' }
  initialize: -> @listenTo @model, 'change', @render
  render: ->
    if @model.get('google')? and @model.get('google')._json.name is 'Maksim Ioffe'
      $log @model.toJSON()

    @$el.html @tmpl @model.toJSON()
    @
  deleteUser: ->
    $log 'deleting', @model.attributes
    @model.destroy()
    @$el.remove()


class exports.UsersView extends BB.BadassView
  el: '#users'
  # events: { 'click .select': 'select' }
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    $list = @$('tbody').html ''
    for m in @collection.models
     $list.append new exports.UserRowView( model: m ).render().el
    # @$('.count').html @collection.models.length
    @
  # select: (e) ->
  #   e.preventDefault()
  #   id = $(e.currentTarget).data('id')
  #   expert = _.find @collection.models, (m) -> m.id.toString() == id
  #   @model.set expert.attributes

class exports.UserView extends BB.BadassView
  el: '#user'
  tmpl: require './templates/Form'

  initialize: (args) ->
    @listenTo @model, 'change', @render
  render: ->
    # @$el.html @model.get('google').displayName
    @$el.html @tmpl @model.toJSON()
    @

module.exports = exports