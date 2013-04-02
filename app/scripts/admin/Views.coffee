exports = {}
BB = require './../../lib/BB'
M = require './Models'
tmpl_links = require './../../templates/devLinks'


#############################################################################
##  Shared
#############################################################################

class DataListView extends BB.BadassView
  events:
    'click .edit': (e) -> @formView.render @getModelFromDataId(e)
    'click .delete': 'destroyRemoveModel'
    'click .detail': (e) -> false
  getModelFromDataId: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    _.find @collection.models, (m) -> m.id is id
  destroyRemoveModel: (e) ->
    m = @getModelFromDataId(e)
    m.destroy()
    @collection.remove m


#############################################################################


class exports.SkillFormView extends BB.ModelSaveView
  el: '#skillFormView'
  tmpl: require './templates/SkillForm'
  viewData: ['name','shortName','soId']
  events:
    'input #skillName': 'auto'
    'click .save': 'save'
    'click .cancel': -> @render new M.Skill(); false
  initialize: ->
  render: (model) ->
    if model? then @model = model
    @$el.html @tmpl @model.toJSON()
    @
  auto: ->
    name = @$('#skillName').val()
    @$('#skillShort').val name
    @$('#skillSoId').val name.toLowerCase().replace(/\ /g,'-')
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.add model
    @render new M.Skill()


class exports.SkillRowView extends BB.BadassView
  className: 'skill label'
  tmpl: require './templates/SkillRow'
  initialize: -> @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @model.toJSON()
    @


class exports.SkillsView extends DataListView
  el: '#skills'
  tmpl: require './templates/Skills'
  initialize: (args) ->
    @$el.html @tmpl()
    @formView = new exports.SkillFormView( model: new M.Skill(), collection: @collection ).render()
    @collection.on 'reset add remove filter', @render, @
  render: ->
    $skillsList = @$('#skillsList').html ''
    for m in @collection.models
      $skillsList.append new exports.SkillRowView( model: m ).render().el
    @$('.skill a').popover({})
    @


#############################################################################


class exports.DevFormView extends BB.ModelSaveView
  el: '#devFormView'
  tmpl: require './templates/DevForm'
  async: off  # async off because we want skills objects back from server
  viewData: ['name','email','gmail','pic', 'homepage', 'gh', 'so', 'bb', 'in', 'other', 'skills', 'rate']
  events: { 'click .save': 'save' }
  initialize: ->
  render: (model) ->
    if model? then @model = model
    tmplData = _.extend @model.toJSON(), { skillsSoIds: @model.skillSoIdsList() }
    @$el.html @tmpl tmplData
    @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.add model
    @render new M.Dev()


class exports.DevRowView extends BB.BadassView
  tagName: 'tr'
  className: 'devRow'
  tmpl: require './templates/DevRow'
  initialize: -> @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @model.toJSON()
    @


class exports.DevsView extends DataListView
  el: '#devs'
  tmpl: require './templates/Devs'
  initialize: (args) ->
    @$el.html @tmpl()
    @formView = new exports.DevFormView( model: new M.Dev(), collection: @collection ).render()
    @collection.on 'reset add remove filter', @render, @
  render: ->
    $tbody = @$('tbody').html ''
    for m in @collection.models
      $tbody.append new exports.DevRowView( model: m ).render().el
    @


#############################################################################


class exports.CompanyContactView extends BB.ModelSaveView
  tmpl: require './templates/CompanyContactForm'
  viewData: ['fullName','email','gmail','title','phone']
  initialize: ->
  render: (attrs) ->
    @model.clear()
    @model.set attrs
    @$el.html @tmpl @model.toJSON()
    @


class exports.CompanyFormView extends BB.ModelSaveView
  el: '#companyFormView'
  tmpl: require './templates/CompanyForm'
  events: { 'click .save': 'validatePrimaryContactAndSave' }
  initialize: ->
    @$el.html @tmpl @model.toJSON()
    @contact1View = new exports.CompanyContactView(el: '#primaryContact', model: new M.CompanyContact(num:1)).render()
    @contact2View = new exports.CompanyContactView(el: '#secondaryContact', model: new M.CompanyContact(num:2)).render()
    @model.on 'change', @render, @
  render: (model) ->
    if model? then @model = model
    @setValsFromModel ['name','url','about']
    @contact1View.render @model.get('contacts')[0]
    @contact2View.render @model.get('contacts')[1]
    @
  getViewData: ->
    data = @getValsFromInputs ['name','url','about']
    data.contacts = [ @contact1View.getViewData(), @contact2View.getViewData() ]
    data
  validatePrimaryContactAndSave: (e) ->
    e.preventDefault()
    $inputName = @$('#primaryContact [name=fullName]')
    $inputEmail = @$('#primaryContact [name=email]')
    @renderInputsValid()
    if $inputName.val() is ''
      @renderInputInvalid $inputName, 'Primary name required'
    else if $inputEmail.val() is ''
      @renderInputInvalid $inputEmail, 'Primary email required'
    else
      @save e
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.add model
    @render new M.Company()


class exports.CompanyRowView extends BB.BadassView
  tagName: 'tr'
  className: 'companyRow'
  tmpl: require './templates/CompanyRow'
  initialize: -> @model.on 'change', @render, @
  render: ->
    tmpl_data = _.extend @model.toJSON(), { }
    @$el.html @tmpl( tmpl_data )
    @


class exports.CompanysView extends DataListView
  el: '#companys'
  tmpl: require './templates/Companys'
  initialize: (args) ->
    @$el.html @tmpl()
    @formView = new exports.CompanyFormView( model: new M.Company(), collection: @collection ).render()
    @collection.on 'reset add remove filter', @render, @
  render: ->
    $tbody = @$('tbody')
    $tbody.html ''
    for m  in @collection.models
      $tbody.append new exports.CompanyRowView( model: m ).render().el
    @


#############################################################################

RequestFormViews = require './ViewsRequestForm'

_.extend exports, RequestFormViews # add our Request forms view to exports

#############################################################################


class exports.RequestRowView extends BB.BadassView
  tagName: 'tr'
  className: 'requestRow'
  tmpl: require './templates/RequestRow'
  render: ->
    @$el.html @tmpl @tmplData()
    @
  tmplData: ->
    data = @model.toJSON()
    #$log 'RequestRowView.tmplData', data
    _.extend @model.toJSON(), {
      createdDate:        @model.createdDateString()
      suggestedCount:     data.suggested.length
      suggestedFitCount:  _.filter(data.suggested, (s) -> s.status is 'chosen').length
      callCount:          data.calls.length
      callCompleteCount:  _.filter(data.calls, (s) -> s.status is 'complete').length
    }


class exports.RequestsView extends BB.BadassView
  el: '#requests'
  tmpl: require './templates/Requests'
  initialize: (args) ->
    @listenTo @collection, 'sync', @render # filter sort
  render: ->
    @$el.html @tmpl( count: @collection.length )
    for m in @collection.models
      if m.get('status') is 'canceled'
        @$('#cancelled tbody').append new exports.RequestRowView( model: m ).render().el
      else if  m.get('status') is 'completed'
        @$('#completed tbody').append new exports.RequestRowView( model: m ).render().el
      else
        @$('#inProgress tbody').append new exports.RequestRowView( model: m ).render().el

    @


Handlebars.registerPartial "devLinks", tmpl_links

module.exports = exports