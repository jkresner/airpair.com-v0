exports                        = {}
BB                             = require 'BB'
M                              = require './Models'

Handlebars.registerPartial "DevLinks", require('./templates/DevLinks')

Handlebars.registerHelper "localDateTime", (utcDateString) ->
  # $log 'moment', moment
  day = moment utcDateString
  day.local().format("MMM DD HH:mm")

Handlebars.registerHelper "localDateTimeSeconds", (utcDateString) ->
  day = moment utcDateString
  day.local().format("MMM DD HH:mm:ss")

Handlebars.registerHelper "callDateTime", (utcDateString) ->
  day = moment utcDateString
  day.format("DD MMM <b>HH:mm</b>")

Handlebars.registerHelper 'markdown', (text) ->
  options =
    sanitize: true
    headerPrefix: '-' # so their ID's don't conflict with our ID's
  result = marked(text, options)
  new Handlebars.SafeString result



class exports.ExpertView extends BB.BadassView
  tmpl: require './templates/Expert'
  initialize: (args) ->
    @listenTo @model, 'change', @render
  render: ->
    d = (_.extend @model.toJSON(), { hasNoLinks: !@model.hasLinks() } )
    @$el.html @tmpl d
    @


#############################################################################
##
#############################################################################

class exports.TagNewForm extends BB.ModelSaveView
  el: '#tagNewForm'
  tmpl: require './templates/TagNewForm'
  viewData: ['nameStackoverflow','nameGithub']
  events:
    'click .save-so': (e) -> @saveWithMode e, 'stackoverflow'
    'click .save-gh': (e) -> @saveWithMode e, 'github'
    'click .cancel': (e) -> @collection.trigger 'sync'; false
  initialize: (args) ->
    @model = new M.Tag()
    @selected = args.selected
    @$el.html @tmpl()
    @$stackName = @elm("nameStackoverflow")
    @listenTo @$stackName, 'change', => @renderInputsValid()
  saveWithMode: (e, mode) ->
    @model.clear()
    @model.set addMode: mode
    @save e
    false
  renderSuccess: (model, response, options) =>
    @$('input').val ''
    @selected.toggleTag model.toJSON()
    @collection.add model
    @collection.trigger 'sync'  # causes the tag form to go away
  renderError: (model, response, options) =>
    @renderInputInvalid @$stackName, 'failed to add tag... is that a valid stackoverflow tag?'


class exports.TagsInputView extends BB.HasBootstrapErrorStateView
  el: '#tagsInput'
  tmpl: require './templates/TagInput'
  tmplAutoResult:  require './templates/TagAutocompleteResult'
  events:
    'click .rmTag': 'deselect'
    'click .new': 'newTag'
  initialize: (args) ->
    @$el.append @tmpl @model.toJSON()
    @newForm = new exports.TagNewForm selected: @model, collection: @collection
    @listenTo @collection, 'sync', @initTypehead
    @listenTo @model, 'change:_id', -> @$auto.val '' # clears it across requests
    @listenTo @model, 'change:tags', @render
    @$auto = @$('.autocomplete').on 'input', =>
      @renderInputValid @$('.autocomplete')
      @renderInputValid @elm('newStackoverflow')
  render: ->
    @$('.error-message').remove() # in case we had an error fire first
    @$('.selected').html ''
    if @model.get('tags')?
      @$('.selected').append(@tagHtml(t)) for t in @model.get('tags')
    @
  tagHtml: (t) ->
    "<span class='label label-tag'>#{t.short} <a href='#{t._id}' title='#{t.name}' class='rmTag'>x</a></span>"
  initTypehead: ->
    # $log 'initTypehead'#, @collection.toJSON()
    @newForm.$el.hide()
    @cleanTypehead().val('').show()
    @$auto.typeahead(
      header: '<header>Tags in our database</header>'
      noresultsHtml: 'No results... <a href="#" class="new"><b>add one</b></a>'
      name: 'collection' + new Date().getTime()
      valueKey: 'short'
      template: @tmplAutoResult
      local: @collection.toJSON()
    ).on('typeahead:selected', @select)
    #@$auto.on 'blur', => @$auto.val ''   # makes it so no value off focus
    @
  select: (e, data) =>
    if e? then e.preventDefault()
    @model.toggleTag data
    @$auto.val ''
  deselect: (e) =>
    e.preventDefault()
    _id = $(e.currentTarget).attr 'href'
    # $log 'deselect', _id, @collection.models.length, @collection.models
    match = _.find @collection.models, (m) -> m.get('_id') == _id
    # $log 'deselect.', match
    @model.toggleTag match.toJSON()
  newTag: (e) =>
    @cleanTypehead().hide()
    @newForm.$el.show()
    @newForm.$('input').val @$('.autocomplete').val()
  cleanTypehead: ->
    @$auto.typeahead('destroy').off 'typeahead:selected'
  getViewData: ->
    if !@model.get('tags')? then undefined else @model.get 'tags'

#############################################################################
##
#############################################################################

class exports.MarketingTagsInputView extends require('./MarketingTagsInputView')

#############################################################################
##
#############################################################################

class exports.StripeRegisterView extends BB.BadassView
  el: '#stripeRegister'
  tmpl: require '/scripts/shared/templates/StripeRegister'
  initialize: (args) ->
    require '/scripts/providers/stripe.v2'
    @model.once 'sync', @render, @
  render: ->
    @$el.html @tmpl meta: @meta()
    @$form = @$('form')
    @$form.on 'submit', (e) =>
      e.preventDefault()
      @$('button').prop 'disabled', true  # Disable submitBtn to prevent repeat clicks
      Stripe.card.createToken @$form, @responseHandler
    @
  responseHandler: (status, response) =>
    if response.error # Show the errors on the form
      @$('.payment-errors').text response.error.message
      @$('button').prop 'disabled', false
    else
      token = response.id  # token contains id, last4, and card type
      @model.save stripeCreate: { token: token, email: @email() }, { success: @stripeCustomerSuccess }
  email: ->
    @session.get('google')._json.email
  meta: -> ''
  stripeCustomerSuccess: (model, resp, opts) =>
    @model.unset 'stripeCreate'
    name = @session.get('google').displayName
    addjs.trackEvent 'request', 'customerSetStripeInfo', name
    addjs.providers.mp.setPeopleProps paymentInfoSet: 'stripe'
    @successAction()
  successAction: => # give the power to override this action so we can put the view in different flows
    router.navTo '#'



# class exports.locationInput = ($el, selector, hidden_selector) ->
#   if google? && google.maps?
#     input = $el.find selector
#     hd = $el.find hidden_selector
#     options = { types: ['(cities)'] }
#     autocomplete = new google.maps.places.Autocomplete(input.get(0), options)

    # http://stackoverflow.com/questions/12816428/how-to-fire-place-changed-event-for-google-places-auto-complete-on-enter-key
    # input.keypress (e) ->
    #   if (e.which == 13)
    #     google.maps.event.trigger(autocomplete, 'place_changed')
    #     false

    # updateInput = ->
    #   Backbone.Validation.renderBootstrapInputValid input
    #   place = autocomplete.getPlace()
    #   if ! place? || ! place.geometry
    #     # Inform the user that the place was not found and return.
    #     Backbone.Validation.renderBootstrapInputInvalid input, 'Place not found'
    #   else
    #     hd.val place.formatted_address

    # set the input string or error when place selected
    # google.maps.event.addListener autocomplete, 'place_changed', updateInput

    # if user changes location_id textbox value after google place_changed was successful
    # input.on 'change', -> hd.val ''


module.exports = exports
