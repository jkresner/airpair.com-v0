exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##  Company
#############################################################################

class exports.CompanyContactView extends BB.ModelSaveView
  tmpl: require './../shared/templates/CompanyContactForm'
  viewData: ['fullName','email','gmail','title','phone']
  initialize: ->
  render: (attrs) ->
    @model.clear()
    @model.set attrs
    @$el.html @tmpl @model.toJSON()
    @


class exports.CompanyFormView extends BB.ModelSaveView
  el: '#companyFormView'
  tmpl: require './../shared/templates/CompanyForm'
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


module.exports = exports