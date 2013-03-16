exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################


class exports.SkillFormView extends BB.BadassView
  el: '#skillFormView'
  tmpl: require './templates/SkillForm'
  events:
    'click .save': 'save'
    'input #skillName': 'auto'
  render: ->
    @$el.html @tmpl @model.toJSON()
    @
  save: (e) ->
    e.preventDefault()
    d = name: $('#skillName').val(), shortName: $('#skillShort').val(), soId: $('#skillSoId').val()
    $log 'saving skill', d, @collection
    @collection.create(d, { success: @success })
  success: (model, options) =>
    @$('input').val ''
  auto: ->
    name = @$('#skillName').val()
    @$('#skillShort').val name
    @$('#skillSoId').val name.toLowerCase()


class exports.SkillRowView extends BB.BadassView
  tagName: 'tr'
  className: 'skillRow'
  tmpl: require './templates/SkillRow'
  render: ->
    @$el.html @tmpl( @model.toJSON() )
    @


class exports.SkillsView extends BB.BadassView
  el: '#skills'
  tmpl: require './templates/Skills'
  initialize: (args) ->
    @$el.html @tmpl()
    @skillFormView = new exports.SkillFormView( model: new M.Skill(), collection: @collection ).render()
    @collection.on 'reset filter sort', @render, @
    @collection.on 'add', @renderNew, @
  render: ->
    for m in @collection.models
      @$('tbody').append new exports.SkillRowView( model: m ).render().el
    @
  renderNew: (model) ->
    @$('tbody').prepend new exports.SkillRowView( model: model ).render().el


#############################################################################


class exports.DevFormView extends BB.BadassView
  el: '#devFormView'
  tmpl: require './templates/DevForm'
  events:
    'click .save': 'save'
  render: ->
    @$el.html @tmpl @model.toJSON()
    @
  save: (e) ->
    e.preventDefault()
    d = @viewData ['name','email','pic', 'homepage', 'gh', 'so', 'bb', 'in', 'other', 'skills', 'rate']
    $log 'saving dev', d, @collection
    @collection.create(d, { success: @success, wait: true })
  success: (model, options) =>
    @$('input').val ''
  viewData: (list) ->
    data = {}
    data[attr] = @$("[name=#{attr}]").val() for attr in list
    $log 'dev.data', data
    data


class exports.DevRowView extends BB.BadassView
  tagName: 'tr'
  className: 'devRow'
  tmpl: require './templates/DevRow'
  tmpl_links: require './../../templates/devLinks'
  render: ->
    tmpl_data = _.extend @model.toJSON(), { skillsList: @model.skillListLabeled() }
    @$el.html @tmpl( tmpl_data )
    @$('.links').html @tmpl_links(@model.toJSON())
    @


class exports.DevsView extends BB.BadassView
  el: '#devs'
  tmpl: require './templates/Devs'
  initialize: (args) ->
    @$el.html @tmpl()
    @devFormView = new exports.DevFormView( model: new M.Dev(), collection: @collection ).render()
    @collection.on 'reset filter sort', @render, @
    @collection.on 'add', @renderNew, @
  render: ->
    for m in @collection.models
      @$('tbody').append new exports.DevRowView( model: m ).render().el
    @
  renderNew: (m) ->
    @$('tbody').prepend new exports.DevRowView( model: m ).render().el



#############################################################################


class exports.CompanyContactView extends BB.ModelSaveView
  logging: on
  tmpl: require './templates/CompanyContactForm'
  initialize: ->
  render: (attrs) ->
    @model.clear()
    @model.set attrs
    @$el.html @tmpl @model.toJSON()
    @
  viewData: -> @getValsFromInputs ['fullName','email','title','phone']


class exports.CompanyFormView extends BB.ModelSaveView
  logging: on
  el: '#companyFormView'
  tmpl: require './templates/CompanyForm'
  events:
    'click .save': 'validatePrimaryContactAndSave'
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
  viewData: ->
    data = @getValsFromInputs ['name','url','about']
    data.contacts = [ @contact1View.viewData(), @contact2View.viewData() ]
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
  render: ->
    tmpl_data = _.extend @model.toJSON(), { }
    @$el.html @tmpl( tmpl_data )
    @


class exports.CompanysView extends BB.BadassView
  logging: on
  el: '#companys'
  tmpl: require './templates/Companys'
  events:
    'click .edit': (e) -> @companyFormView.render @getCompany(e)
    'click .delete': 'destroyRemoveCompany'
    'click .detail': (e) -> false
  initialize: (args) ->
    @$el.html @tmpl()
    @companyFormView = new exports.CompanyFormView( model: new M.Company(), collection: @collection ).render()
    $log 'companyFormView', @companyFormView
    @collection.on 'reset remove filter sort', @render, @
  render: ->
    @$('tbody').html ''
    for m in @collection.models
      @$('tbody').append new exports.CompanyRowView( model: m ).render().el
    @
  getCompany: (e) ->
    e.preventDefault()
    cid = $(e.currentTarget).data('id')
    _.find @collection.models, (m) -> m.id is cid
  destroyRemoveCompany: (e) ->
    comp = @getCompany(e)
    comp.destroy()
    @collection.remove comp



#############################################################################

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

#############################################################################

class exports.LeadView extends BB.BadassView
  el: '#lead'
  tmpl: require './templates/Lead'
  mailTmpl: require './../../mail/developerMatched'
  mailTmpl2: require './../../mail/developersContacted'
  events:
    'click a.mailMatched': 'sendMatchedMail'
    'click a#mailDevsContacted': 'sendDevsContacted'
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
  sendMatchedMail: (e) ->
    e.preventDefault()
    devId = parseInt $(e.currentTarget).attr('data-id')
    skillList = @model.skillList()
    developers = _.pluck @model.get('suggested'), 'dev'
    dev = _.find developers, (d) -> d.id == devId
    mailtoAddress = "#{dev.name}%20%3c#{dev.email}%3e"
    body = @mailTmpl dev_name: dev.name, entrepreneur_name: @model.get('contacts')[0].name, leadId: @model.id
    window.location.href = "mailto:#{mailtoAddress}?subject=airpair - Help an entrepreneur with#{skillList}?&body=#{body}"
  sendDevsContacted: (e) ->
    e.preventDefault()
    customer = @model.get('contacts')[0]
    mailtoAddress = "#{customer.name}%20%3c#{customer.email}%3e"
    body = @mailTmpl2 entrepreneur_name: customer.name, leadId: @model.id
    window.location.href = "mailto:#{mailtoAddress}?subject=airpair - We're waiting to hear back from our devs!&body=#{body}"


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