exports = {}
BB = require './../../lib/BB'


class exports.InProgressLeadRowView extends BB.BadassView
  tagName: 'tr'
  className: 'leadRow'
  tmpl: require './templates/InProgressLeadRow'
  render: ->
    @$el.html @tmpl( @tmplData() )
    @
  tmplData: ->
    data = @model.toJSON()

    _.extend @model.toJSON(), {
      createdDate:        data.created.toDateString()
      skillList:          @model.skillList()
      breifSupplied:      if data.brief? then 'y' else '-'
      suggestedCount:     data.suggested.count
      suggestedFitCount:  0
      callCount:          data.calls.count
      callCompleteCount:  0
    }


class exports.InProgressLeadsView extends BB.BadassView
  el: '#inProgressLeads'
  tmpl: require './templates/InProgressLeads'
  initialize: (args) ->
    @collection.on 'reset filter sort', @render, @
  render: ->
    @$el.html @tmpl( count: @collection.length )
    for m in @collection.models
      @$('tbody').append new exports.InProgressLeadRowView( model: m ).render().el
    @


class exports.LeadView extends BB.BadassView
  el: '#lead'
  tmpl: require './templates/Lead'
  initialize: (args) ->
    @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @tmplData()
  tmplData: ->
    data = @model.toJSON()

    _.extend @model.toJSON(), {
      createdDate:        data.created.toDateString()
      skillList:          @model.skillList()
    }

module.exports = exports