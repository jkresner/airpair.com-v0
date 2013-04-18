exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
##  Shared
#############################################################################

#############################################################################


class exports.CompanyContactView extends BB.ModelSaveView
  tmpl: require './../shared/templates/CompanyContactForm'
  viewData: ['fullName','email','gmail','title','phone','userId',
                                'avatarUrl', 'twitter','timezone']
  initialize: ->
  render: (attrs) ->
    @model.clear()
    @model.set attrs
    @$el.html @tmpl @model.toJSON()
    @


class exports.CompanyFormView extends BB.ModelSaveView
  el: '#companyForm'
  tmpl: require './../shared/templates/CompanyForm'
  events: { 'click .save': 'validatePrimaryContactAndSave' }
  initialize: ->
    @$el.html @tmpl @model.toJSON()
    @contactView = new exports.CompanyContactView(el: '#primaryContact', model: new M.CompanyContact(num:1)).render()
    @model.on 'change', @render, @
  render: (model) ->
    if model? then @model = model
    @setValsFromModel ['name','url','about']
    @contactView.render @model.get('contacts')[0]
    @
  getViewData: ->
    data = @getValsFromInputs ['name','url','about']
    data.contacts = [ @contactView.getViewData() ]
    data
  validatePrimaryContactAndSave: (e) ->
    e.preventDefault()
    $inputName = @$('#contacts [name=fullName]')
    $inputEmail = @$('#contacts [name=email]')
    @renderInputsValid()
    if $inputName.val() is ''
      @renderInputInvalid $inputName, 'Contact name required'
    else if $inputEmail.val() is ''
      @renderInputInvalid $inputEmail, 'Contact email required'
    else
      @save e
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    router.navigate 'request', { trigger: true }


#############################################################################

class exports.RequestFormView extends BB.ModelSaveView
  logging: on
  el: '#requestForm'
  tmpl: require './templates/RequestForm'
  viewData: ['brief']
  events:
    'click .save': 'save'
  initialize: ->
    @$el.html @tmpl @model.toJSON()
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @availabiltyInput = new SV.AvailabiltyInputView model: @model, collection: @tags
    @$('input:radio').on 'click', @selectRB
    @listenTo @model, 'change', @render
  render: ->
    @setValsFromModel ['brief']
    @tagsInput.render()
    @availabiltyInput.render()
    @
  selectRB: (e) ->
    rb = $(e.currentTarget)
    group = rb.parent()
    group.find("label").removeClass 'checked'
    rb.prev().addClass 'checked'
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
  getViewData: ->
    budget: @$("[name='budget']:checked").val()
    pricing: @$("[name='pricing']:checked").val()
    brief: @$("[name='brief']").val()
    avilability: @availabiltyInput.getViewData()
    tags: @tagsInput.getViewData()


#############################################################################


module.exports = exports