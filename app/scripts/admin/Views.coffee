exports = {}
BB = require './../../lib/BB'
tmpl_mail_developerMatched = require './../../mail/developerMatched'

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
      createdDate:        data.created.toDateString().replace(' 2013','')
      skillList:          @model.skillListLabeled()
      breifSupplied:      if data.brief? then 'y' else '-'
      suggestedCount:     data.suggested.length
      suggestedFitCount:  _.filter(data.suggested, (s) -> s.status is 'chosen').length
      callCount:          data.calls.length
      callCompleteCount:  _.filter(data.calls, (s) -> s.status is 'complete').length
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
  events:
    'click a.mailMatched': 'sendMatchedMail'
  initialize: (args) ->
    $log 'LeadView.init', @model.attributes
    @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @tmplData()
  tmplData: ->
    data = @model.toJSON()

    _.extend @model.toJSON(), {
      createdDate:        data.created.toDateString()
      skillList:          @model.skillList()
    }
  sendMatchedMail: (e) ->
    e.preventDefault()
    devId = parseInt $(e.currentTarget).attr('data-id')
    skillList = @model.skillList()
    developers = _.pluck @model.get('suggested'), 'dev'
    dev = _.find developers, (d) -> d.id == devId
    mailtoAddress = "#{dev.name}%20%3c#{dev.email}%3e"
    body = tmpl_mail_developerMatched dev_name: dev.name, entrepreneur_name: @model.get('contacts')[0].name, leadId: @model.id
    window.location.href = "mailto:#{mailtoAddress}?subject=airpair - help an entrepreneur with#{skillList}?&body=#{body}"


class exports.ReviewView extends BB.BadassView
  el: '#review'
  tmpl: require './templates/Review'
  initialize: (args) ->
    @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @tmplData()
  tmplData: ->
    data = @model.toJSON()
    _.extend @model.toJSON(), {
      createdDate:        data.created.toDateString()
      skillList:          @model.skillListLabeled()
    }






module.exports = exports