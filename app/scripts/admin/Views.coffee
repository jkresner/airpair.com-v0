exports = {}
BB = require './../../lib/BB'
M = require './Models'


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
    'click .save': 'save'
    'input #skillName': 'auto'
  initialize: ->
  render: (model) ->
    if model? then @model = model
    @$el.html @tmpl @model.toJSON()
    @
  auto: ->
    name = @$('#skillName').val()
    @$('#skillShort').val name
    @$('#skillSoId').val name.toLowerCase()
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
  viewData: ['name','email','pic', 'homepage', 'gh', 'so', 'bb', 'in', 'other', 'skills', 'rate']
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
  tmpl_links: require './../../templates/devLinks'
  initialize: -> @model.on 'change', @render, @
  render: ->
    tmpl_data = _.extend @model.toJSON(), { skillsList: @model.skillListLabeled() }
    @$el.html @tmpl tmpl_data
    @$('.links').html @tmpl_links tmpl_data
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


class exports.RequestFormView extends BB.ModelSaveView
  logging: on
  async: off
  el: '#requestForm'
  tmpl: require './templates/RequestForm'
  viewData: ['companyId','status','skills','brief','canceledReason']
  events:
    'click .save': 'save'
    'click .suggestDev': 'suggestDev'
    'click .deleteSuggested': 'suggestRemove'
  initialize: ->
    @model.on 'change', @render, @
    @companys.on 'reset', @render, @
    @devs.on 'reset', @render, @
  render: (model) ->
    if model? && model.set? then @model = model
    tmplData = _.extend @model.toJSON(), { companys: @companys.toJSON(), devs: @devs.toJSON(), skillsSoIds: @model.skillSoIdsList() }
    @$el.html @tmpl tmplData
    @$('#reqCompany').val @model.get 'companyId'
    @$('#reqStatus').val @model.get 'status'
    @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    @collection.fetch()
  suggestDev: (e) ->
    # todo, check for duplicates
    @model.get('suggested').push
      status: 'unconfirmed'
      events: [{'created': new Date() }]
      dev: { _id: @$('#reqDev').val(), name: @$('#reqDev option:selected').text() }
      availability: []
      comment: ''
    @save e
    @render()
  suggestRemove: (e) ->
    suggestionId = $(e.currentTarget).data 'id'
    toRemove = _.find @model.get('suggested'), (d) -> d._id = suggestionId
    $log 'suggestRemove', suggestionId, toRemove
    @model.set 'suggested', _.without( @model.get('suggested'), toRemove )
    @save e
    @render()
  getViewData: ->
    d = @getValsFromInputs @viewData
    d.companyName = @$('#reqCompany option:selected').text()
    d

#############################################################################


class exports.RequestRowView extends BB.BadassView
  tagName: 'tr'
  className: 'requestRow'
  tmpl: require './templates/RequestRow'
  render: ->
    @$el.html @tmpl( @tmplData() )
    @
  tmplData: ->
    data = @model.toJSON()
    #$log 'RequestRowView.tmplData', data
    _.extend @model.toJSON(), {
      createdDate:        new Date(data.events[0].utc).toDateString().replace(' 2013','')
      skillList:          @model.skillListLabeled()
      breifSupplied:      if data.brief? then 'y' else '-'
      suggestedCount:     data.suggested.length
      suggestedFitCount:  _.filter(data.suggested, (s) -> s.status is 'chosen').length
      callCount:          data.calls.length
      callCompleteCount:  _.filter(data.calls, (s) -> s.status is 'complete').length
    }


class exports.RequestsView extends BB.BadassView
  el: '#requests'
  tmpl: require './templates/Requests'
  initialize: (args) ->
    @collection.on 'reset filter sort', @render, @
  render: ->
    @$el.html @tmpl( count: @collection.length )
    for m in @collection.models
      @$('tbody').append new exports.RequestRowView( model: m ).render().el
    @

#############################################################################

# class exports.LeadView extends BB.BadassView
#   el: '#lead'
#   tmpl: require './templates/Lead'
#   mailTmpl: require './../../mail/developerMatched'
#   mailTmpl2: require './../../mail/developersContacted'
#   events:
#     'click a.mailMatched': 'sendMatchedMail'
#     'click a#mailDevsContacted': 'sendDevsContacted'
#   initialize: (args) ->
#     @model.on 'change', @render, @
#   render: ->
#     @$el.html @tmpl @tmplData()
#   tmplData: ->
#     data = @model.toJSON()

#     _.extend @model.toJSON(), {
#       createdDate:        data.created.toDateString()
#       skillList:          @model.skillList()
#     }
#   sendMatchedMail: (e) ->
#     e.preventDefault()
#     devId = parseInt $(e.currentTarget).attr('data-id')
#     skillList = @model.skillList()
#     developers = _.pluck @model.get('suggested'), 'dev'
#     dev = _.find developers, (d) -> d.id == devId
#     mailtoAddress = "#{dev.name}%20%3c#{dev.email}%3e"
#     body = @mailTmpl dev_name: dev.name, entrepreneur_name: @model.get('contacts')[0].name, leadId: @model.id
#     window.location.href = "mailto:#{mailtoAddress}?subject=airpair - Help an entrepreneur with#{skillList}?&body=#{body}"
#   sendDevsContacted: (e) ->
#     e.preventDefault()
#     customer = @model.get('contacts')[0]
#     mailtoAddress = "#{customer.name}%20%3c#{customer.email}%3e"
#     body = @mailTmpl2 entrepreneur_name: customer.name, leadId: @model.id
#     window.location.href = "mailto:#{mailtoAddress}?subject=airpair - We're waiting to hear back from our devs!&body=#{body}"


# class exports.ReviewView extends BB.BadassView
#   el: '#review'
#   tmpl: require './templates/Review'
#   initialize: (args) ->
#     @model.on 'change', @render, @
#   render: ->
#     @$el.html @tmpl @tmplData()
#   tmplData: ->
#     data = @model.toJSON()
#     _.extend @model.toJSON(), {
#       createdDate:        data.created.toDateString()
#       skillList:          @model.skillListLabeled()
#     }



module.exports = exports