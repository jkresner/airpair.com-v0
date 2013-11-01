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
  events: { 'click .track': 'track' }
  initialize: ->
    @e = addjs.events.customerLogin
    @e2 = addjs.events.customerWelcome
  render: ->
    if !@timer? then @timer = new addjs.Timer(@e.category).start()    
    @$el.html @tmpl()
    trackWelcome = => addjs.trackEvent @e2.category, @e2.name, @e2.uri, 0
    setTimeout trackWelcome, 400
  track: (e) =>
    e.preventDefault()
    addjs.trackEvent @e.category, @e.name, @e.uri, @timer.timeSpent()
    setTimeout @oauthRedirect, 400
  oauthRedirect: ->
    window.location = "/auth/google?return_to=/find-an-expert&mixpanelId=#{mixpanel.get_distinct_id()}"


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
  # logging: on
  el: '#info'
  tmpl: require './../shared/templates/CompanyForm'
  events: { 'click .save': 'validatePrimaryContactAndSave' }
  initialize: ->
    @e = addjs.events.customerInfoNew
    @$el.html @tmpl @model.toJSON()
    @contactView = new exports.CompanyContactView(el: '#primaryContact', model: new M.CompanyContact(num:1)).render()
    @model.on 'change', @render, @
    @model.once 'change', => @isReturnCustomer = @model.id?  
  render: ->
    if !@timer? then @timer = new addjs.Timer(@e.category).start()
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
    if @isReturnCustomer
      @e.name = "customerInfoRepeat"
    addjs.trackEvent @e.category, @e.name, @elm('fullName').val(), @timer.timeSpent()
    addjs.providers.mp.setPeopleProps isCustomer : 'Y'
    router.navTo 'request'


#############################################################################
##  Request form
#############################################################################

class exports.RequestFormView extends BB.ModelSaveView
  # logging: on
  el: '#requestForm'
  tmpl: require './templates/RequestForm'
  events:
    'click .save': 'save'
  initialize: ->
    @e = addjs.events.customerRequest
    @$el.html @tmpl {}
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @$('input:radio').on 'click', @selectRB
    @$('.pricing input:radio').on 'click', @showPricingExplanation
    @$('.budget input:radio').on 'click', @showBudgetExplanation
    @listenTo @model, 'change', @render
    @model.once 'change', => @isRequestUpdate = @model.id?  
    @elm('brief').on 'input', =>
      @$('#breifCount').html(@elm('brief').val().length+ ' chars')
  render: ->
    if !@timer? then @timer = new addjs.Timer(@e.category).start()
    if @model.hasChanged('tags') then return
    @$(".stepNum").toggle !@model.get('_id')?
    @setValsFromModel ['brief','availability','hours']
    @$(":radio[value=#{@model.get('budget')}]").click().prop('checked',true)
    @$(":radio[value=#{@model.get('pricing')}]").click().prop('checked',true)
    @$(".pricingOpensource span").html (-1*@model.opensource)
    @$(".pricingNDA span").html @model.nda
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
    val = @$("[name='budget']:checked").attr('id')
    @$(".#{val}").show()
    @showPricingExplanation()
  showPricingExplanation: =>
    @$('.pricingExplanation').hide()
    val = @$("[name='pricing']:checked").val()
    i = 1
    for r in @model.rates val
      #$log 'r',r
      @$("#budget#{i}").prev().html "$#{r}"
      @$("#budget#{i}").val r
      i++
    # add = 0
    # base = parseInt(@$("[name='budget']:checked").val())
    # if val is 'private' then add = 20
    # if val is 'nda' then add = 60
    # @$('.calcph').html("$#{base} + <i>$#{add}</i> = $#{base+add}")
    @$(".#{val}").show()
  renderSuccess: (model, response, options) =>
    if @isRequestUpdate
      @e.name = "customerRequestUpdate"
    else
      addjs.providers.mp.incrementPeopleProp "requestCount"

    addjs.trackEvent @e.category, @e.name, @model.contact(0).fullName, @timer.timeSpent()

    router.navTo 'confirm'
  getViewData: ->
    brief: @elm("brief").val()
    hours: @elm("hours").val()
    availability: @elm("availability").val()
    budget: @$("[name='budget']:checked").val()
    pricing: @$("[name='pricing']:checked").val()
    tags: @tagsInput.getViewData()


class exports.ConfirmEmailView extends BB.EnhancedFormView
  logging: on
  el: '#confirm'
  tmpl: require './templates/ConfirmEmail'
  events: { 'click .save': 'saveEmail' }
  viewData: ['email']
  initialize: ->
    @e = addjs.events.customerEmailConfirm
    @listenTo @model, 'change:contacts', @render
  saveEmail: (e) ->
    e.preventDefault()
    confirmedEmail = @elm('email').val()
    currentEmail = @model.get('contacts')[0].email
    if confirmedEmail == currentEmail
      @renderSuccess()
      addjs.trackEvent @e.category, 'customerEmailChange', currentEmail+'|'+confirmedEmail
    else 
      @save e
  getViewData: ->
    email = @elm('email').val()
    contacts = @model.get('contacts')
    contacts[0].email = email
    contacts: contacts
  render: ->
    @$el.html @tmpl { email: @model.get('contacts')[0].email }
    @
  renderSuccess: (model, response, options) =>
    addjs.trackEvent @e.category, @e.name, @model.get('contacts')[0].fullName
    @request.save 'company': @model.attributes
    router.navTo 'thanks'


#############################################################################


module.exports = exports
