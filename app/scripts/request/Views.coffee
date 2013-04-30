exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
##  Contact Info
#############################################################################

class exports.CompanyContactView extends BB.ModelSaveView
  tmpl: require './../shared/templates/CompanyContactForm'
  viewData: ['fullName','email','gmail','title','phone','userId',
                                'pic', 'twitter','timezone']
  initialize: ->
  render: (attrs) ->
    @model.clear()
    @model.set attrs
    @$el.html @tmpl @model.toJSON()
    @


class exports.ContactInfoView extends BB.ModelSaveView
  el: '#contactInfo'
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
    @$(".btn-cancel").toggle @request.get('_id')?
    @$(".stepNum").toggle !@request.get('_id')?
    @
  getViewData: ->
    data = @getValsFromInputs ['name','url','about']
    data.contacts = [ @contactView.getViewData() ]
    data
  validatePrimaryContactAndSave: (e) ->
    e.preventDefault()
    $inputName = @$('[name=fullName]')
    $inputEmail = @$('[name=email]')
    @renderInputsValid()
    if $inputName.val() is ''
      @renderInputInvalid $inputName, 'Contact name required'
    else if $inputEmail.val() is ''
      @renderInputInvalid $inputEmail, 'Contact email required'
    else
      @save e
  renderSuccess: (model, response, options) =>
    router.navigate 'request', { trigger: true }


#############################################################################

class exports.RequestFormView extends BB.ModelSaveView
  logging: on
  el: '#requestForm'
  tmpl: require './templates/RequestForm'
  # viewData: ['brief','availability']
  events:
    'click .save': 'save'
  initialize: ->
    @$el.html @tmpl {}
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    # @availabilityInput = new SV.AvailabiltyInputView model: @model, collection: @tags
    @$('input:radio').on 'click', @selectRB
    @$('.pricing input:radio').on 'click', @showPricingExplanation
    @listenTo @model, 'change', @render
  render: ->
    @$(".stepNum").toggle !@model.get('_id')?
    @setValsFromModel ['brief','availability','hours']
    @$(":radio[value=#{@model.get('budget')}]").click().prop('checked',true)
    @$(":radio[value=#{@model.get('pricing')}]").click().prop('checked',true)
    @showPricingExplanation()
    @
  selectRB: (e) =>
    rb = $(e.currentTarget)
    group = rb.parent()
    group.find("label").removeClass 'checked'
    rb.prev().addClass 'checked'
  showPricingExplanation: =>
    @$('.pricingExplanation').hide()
    val = @$("[name='pricing']:checked").val()
    @$(".#{val}").show()
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    router.navigate '#thanks', { trigger: true }
  getViewData: ->
    hours: @$("[name='hours']").val()
    budget: @$("[name='budget']:checked").val()
    pricing: @$("[name='pricing']:checked").val()
    brief: @$("[name='brief']").val()
    availability: @$("[name='availability']").val()
    tags: @tagsInput.getViewData()


#############################################################################


module.exports = exports