exports = {}
BB = require './../../lib/BB'
M = require './Models'
Shared = require './../shared/Views'


#############################################################################
##  To render all companies for admin
#############################################################################

class exports.CompanyRowView extends BB.BadassView
  tagName: 'tr'
  className: 'company'
  tmpl: require './templates/CompanyRow'
  events:
    'click .deleteCompany': 'deleteCompany'
    'click .select': 'logToConsole'
  initialize: -> @listenTo @model, 'change', @render
  render: ->
    created = new Date(parseInt(@model.id.toString().slice(0,8), 16)*1000)
    @$el.html @tmpl @model.extend { c: @model.get('contacts')[0], created:created }
    @
  deleteCompany: ->
    # $log 'deleting', @model.attributes, @$el
    @model.destroy()
    @$el.remove()
  logToConsole: ->
    $log 'company.selected', @model.attributes


class exports.CompanysView extends BB.BadassView
  el: '#companys'

  initialize: (args) ->
    @listenTo @collection, 'reset filter', @render
  render: ->
    $list = @$('tbody').html ''
    for m in @collection.models.reverse()
     $list.append new exports.CompanyRowView( model: m ).render().el
    @

#############################################################################
##  To render all users for admin
#############################################################################

class exports.UserRowView extends BB.BadassView
  tagName: 'tr'
  className: 'user'
  tmpl: require './templates/UserRow'
  events: { 'click .deleteUser': 'deleteUser' }
  initialize: -> @listenTo @model, 'change', @render
  render: ->
    if @model.get('google')? and @model.get('google')._json.name is 'Maksim Ioffe'
      $log @model.toJSON()

    created = new Date(parseInt(@model.id.toString().slice(0,8), 16)*1000)
    @$el.html @tmpl @model.extend {created}

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
    for m in @collection.models.reverse()
     $list.append new exports.UserRowView( model: m ).render().el
    # @$('.count').html @collection.models.length
    @
  # select: (e) ->
  #   e.preventDefault()
  #   id = $(e.currentTarget).data('id')
  #   expert = _.find @collection.models, (m) -> m.id.toString() == id
  #   @model.set expert.attributes

# class exports.UserView extends BB.ModelSaveView
#   el: '#user'
#   tmpl: require './templates/Form'
#   viewData: ['email']
#   events:
#     'click .save': 'save'
#   initialize: (args) ->
#     @listenTo @model, 'change', @render
#   render: ->
#     # @$el.html @model.get('google').displayName
#     @$el.html @tmpl @model.toJSON()
#     @

module.exports = exports