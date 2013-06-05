exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
##
#############################################################################

class exports.WelcomeView extends BB.BadassView
  el: '#welcome'
  tmpl: require './templates/Welcome'
  render: -> @$el.html @tmpl()

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


class exports.InfoFormView extends BB.EnhancedFormView
  el: '#info'
  tmpl: require './../shared/templates/CompanyForm'
  events: { 'click .save': 'validatePrimaryContactAndSave' }
  initialize: ->
    @$el.html @tmpl @model.toJSON()
    @contactView = new exports.CompanyContactView(el: '#primaryContact', model: new M.CompanyContact(num:1)).render()
    @model.on 'change', @render, @
  render: ->
    @setValsFromModel ['name','url','about']
    @contactView.render @model.get('contacts')[0]
    @$(".btn-cancel").toggle @request.id?
    @$(".stepNum").toggle !@request.id?
    @enableCharCount 'about'
    @
  getViewData: ->
    data = @getValsFromInputs ['name','url','about']
    data.contacts = [ @contactView.getViewData() ]
    data
  validatePrimaryContactAndSave: (e) ->
    e.preventDefault()
    $inputName = @elm('fullName')
    $inputEmail = @elm('email')
    @renderInputsValid()
    if $inputName.val() is ''
      @renderInputInvalid $inputName, 'Contact name required'
    else if $inputEmail.val() is ''
      @renderInputInvalid $inputEmail, 'Contact email required'
    else
      @save e
  renderSuccess: (model, response, options) =>
    router.navTo 'request'


#############################################################################
##  Request form
#############################################################################

class exports.RequestFormView extends BB.ModelSaveView
  el: '#requestForm'
  tmpl: require './templates/RequestForm'
  events:
    'click .save': 'save'
  initialize: ->
    @$el.html @tmpl {}
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @$('input:radio').on 'click', @selectRB
    @$('.pricing input:radio').on 'click', @showPricingExplanation
    @$('.budget input:radio').on 'click', @showBudgetExplanation
    @listenTo @model, 'change', @render
    @$('[name="brief"]').on 'input', =>
      @$('#breifCount').html(@$('[name="brief"]').val().length+ ' chars')
  render: ->
    if @model.hasChanged('tags') then return
    @$(".stepNum").toggle !@model.get('_id')?
    @setValsFromModel ['brief','availability','hours']
    @$(":radio[value=#{@model.get('budget')}]").click().prop('checked',true)
    @$(":radio[value=#{@model.get('pricing')}]").click().prop('checked',true)
    @showBudgetExplanation()
    @showPricingExplanation()
    @
  selectRB: (e) =>
    rb = $(e.currentTarget)
    group = rb.parent()
    group.find("label").removeClass 'checked'
    rb.prev().addClass 'checked'
  showBudgetExplanation: =>
    @$('.budgetExplanation').hide()
    val = @$("[name='budget']:checked").val()
    @$(".#{val}").show()
    @showPricingExplanation()
  showPricingExplanation: =>
    @$('.pricingExplanation').hide()
    val = @$("[name='pricing']:checked").val()
    add = 0
    base = parseInt(@$("[name='budget']:checked").val())
    if val is 'private' then add = 20
    if val is 'nda' then add = 60
    @$('.calcph').html("$#{base} + <i>$#{add}</i> = $#{base+add}")
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