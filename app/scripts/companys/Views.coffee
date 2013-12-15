exports = {}
BB = require './../../lib/BB'
M = require './Models'
Shared = require './../shared/Views'
Settings = require './../settings/Views'

#############################################################################
##  To collect the card
#############################################################################

class exports.StripeRegisterView extends Settings.StripeRegisterView


class exports.CardEditView extends BB.ModelSaveView
  logging: on
  el: '#editcard'
  tmpl: require './templates/CardEdit'
  viewData: []
  events:
    'click .share': 'shareCard'
    'click .unshare': 'unshareCard'
    'click .remove': 'removeCard'
  initialize: (args) ->
    @listenTo @updates, 'change', @render
    @listenTo @model, 'change', @render
  render: ->
    if !@model.id? then return
    card = @updates.attributes.card
    cardJSON = JSON.stringify card
    @$el.html @tmpl @model.extendJSON { cardJSON, card }
  shareCard: (e) ->
    email = @elm('shareEmail').val()
    card = @updates.get 'card'
    $log 'shareCard', email, card
    @model.set 'share', { email, card }
    @save e
  unshareCard: ->

  removeCard: ->


class exports.CardsView extends BB.BadassView
  el: '#cards'
  tmpl: require './templates/CardRow'
  initialize: (args) ->
    @listenTo @model, 'change', @render
  render: ->
    $list = @$('tbody').html ''
    for m in @model.get 'paymentMethods'
      $list.append @tmpl m
    @


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

# class exports.UserRowView extends BB.BadassView
#   tagName: 'tr'
#   className: 'user'
#   tmpl: require './templates/UserRow'
#   events: { 'click .deleteUser': 'deleteUser' }
#   initialize: -> @listenTo @model, 'change', @render
#   render: ->
#     if @model.get('google')? and @model.get('google')._json.name is 'Maksim Ioffe'
#       $log @model.toJSON()

#     created = new Date(parseInt(@model.id.toString().slice(0,8), 16)*1000)
#     @$el.html @tmpl @model.extend {created}
#     @
#   deleteUser: ->
#     $log 'deleting', @model.attributes
#     @model.destroy()
#     @$el.remove()


# class exports.UsersView extends BB.BadassView
#   el: '#users'
#   # events: { 'click .select': 'select' }
#   initialize: (args) ->
#     @listenTo @collection, 'reset add remove filter', @render
#   render: ->
#     $list = @$('tbody').html ''
#     for m in @collection.models.reverse()
#      $list.append new exports.UserRowView( model: m ).render().el
#     # @$('.count').html @collection.models.length
#     @
  # select: (e) ->
  #   e.preventDefault()
  #   id = $(e.currentTarget).data('id')
  #   expert = _.find @collection.models, (m) -> m.id.toString() == id
  #   @model.set expert.attributes

module.exports = exports
