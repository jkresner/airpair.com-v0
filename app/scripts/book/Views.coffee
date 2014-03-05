exports = {}
BB      = require './../../lib/BB'
M       = require './Models'
SV      = require './../shared/Views'

#############################################################################
##
#############################################################################


class exports.WelcomeView extends BB.BadassView
  el: '#welcome'
  tmpl: require './templates/Welcome'
  events: { 'click .track': 'track' }
  initialize: ->
    @$el.html @tmpl()
    @listenTo @model, 'change', @render
  render: ->
    @$('#bookme-login').html "Login to book hours with #{@model.get('name')}"


class exports.RequestView extends BB.BadassView
  el: '#request'
  initialize: ->


class exports.ExpertView extends BB.BadassView
  logging: on
  el: '#expert'
  tmpl: require './templates/Expert'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    @$el.html @tmpl @model.toJSON()

# class exports.SigninView extends BB.BadassView
#   el: '#signin'
#   events: { 'click .track': 'track' }
#   initialize: ->
#     @e = addjs.events.customerLogin
#     @e2 = addjs.events.customerBookExpert
#   render: ->
#     @$el.html @tmpl()
#     trackWelcome = => addjs.trackEvent @e2.category, @e2.name, @e2.uri, 0
#     setTimeout trackWelcome, 400
#   track: (e) =>
#     e.preventDefault()
#     # addjs.trackEvent @e.category, @e.name, @e.uri, @timer.timeSpent()
#     setTimeout @oauthRedirect, 400
#     false
#   oauthRedirect: ->
#     window.location =
#       "/auth/google?return_to=#{window.location.pathname}&mixpanelId=#{mixpanel.get_distinct_id()}"


module.exports = exports
