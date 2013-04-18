exports = {}
BB = require './../../lib/BB'
M = require './Models'
tmpl_links = require './../shared/templates/DevLinks'


class exports.ReviewView extends BB.BadassView
  el: '#review'
  tmpl: require './templates/Review'
  initialize: (args) ->
  render: ->
    if @model.get('events').length > 0 && @model.get('company')?
      tmplData = @tmplData()
      @$el.html @tmpl tmplData
    @
  tmplData: ->
    d = @model.toJSON()
    #$log 'd', d
    d.brief = d.brief.replace(/\n/g, '<br />')
    #if d.company.about?
    #  d.company.about = d.company.about(/\n/g, '<br />')
    _.extend d,
      createdDate:        @model.createdDateString()

Handlebars.registerPartial "devLinks", tmpl_links


module.exports = exports