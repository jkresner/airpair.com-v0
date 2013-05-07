exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
##  To render requests
#############################################################################


class exports.RequestCustomerSuggestionsView extends BB.BadassView
  logging: on
  el: '.suggestions'
  tmpl: require './templates/CustomerSuggestions'
  initialize: (args) ->
    @model.on 'change', @render, @
  render: ->
    $log 'ek', @$el
    @$el.html @tmpl @model.toJSON()
    @


class exports.RequestInfoView extends BB.BadassView
  logging: on
  el: '#requestInfo'
  tmpl: require './templates/Info'
  initialize: (args) ->
    @model.on 'change', @render, @
  render: ->
    if @model.get('company')?
      isOwner = @model.get('userId') == @session.get('_id')
      tmplData = _.extend @model.toJSON(), { isOwner: isOwner, total: @hrTotal() }
      @$el.html @tmpl tmplData
      if true
        @suggestionsView = new exports.RequestCustomerSuggestionsView(model: @model, session: @session).render().el
      else
        @$('.suggestions').html 'please leave your feedback'
    @
  hrTotal: ->
    tot = @model.get('budget')
    pricing = @model.get('pricing')
    if pricing is 'private' then tot = tot+20
    if pricing is 'nda' then tot = tot+60
    tot


Handlebars.registerPartial "Expert", require('./../shared/templates/Expert')


module.exports = exports