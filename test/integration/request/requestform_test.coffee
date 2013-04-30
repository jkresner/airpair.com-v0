{_, $, $log, Backbone} = window
hlpr = require '/test/ui-helper'
# BB = require 'lib/BB'
M = require '/scripts/request/Models'
C = require '/scripts/request/Collections'
V = require '/scripts/request/Views'
data =
  requests: require './../../data/requests'
  tags: require './../../data/tags'

fixture = """<div id='welcome' class='main'>welcome</div>
      <div id='contactInfo' class='main'>info</div>
       <div id="requestForm"></div>"""

describe 'Request:Views RequestFormView =>', ->

  before ->
    $log 'Request:Views RequestFormView'
    @SPA = hlpr.set_initSPA '/scripts/request/App'

  beforeEach ->
    hlpr.clean_setup @, fixture
    @defaultData = brief: 'test brief', availability: "I am available", budget: 30, pricing: 'private', hours: '1'
    @request = new M.Request()
    @tags = new C.Tags( data.tags )
    @viewData = model: @request, tags: @tags

  afterEach ->
    # hlpr.clean_tear_down @

  # it 'on load sets correct {budget, pricing} radios, {brief, availability} ', ->
  #   $log '@viewData ', @viewData
  #   v = new V.RequestFormView @viewData
  #   v.model.set @defaultData
  #   expect( v.$('#budget30').is(':checked') ).to.be.true
  #   expect( v.$('#budget30').prev().hasClass('checked') ).to.be.true
  #   expect( v.$('#pricingPrivate').is(':checked') ).to.be.true
  #   expect( v.$('#pricingPrivate').prev().hasClass('checked') ).to.be.true
  #   expect( v.$('[name=availability]').val() ).to.be.equal "I am available"
  #   expect( v.$('[name=brief]').val() ).to.be.equal "test brief"
  #   expect( v.$('[name=hours]').val() ).to.equal '1'

  # it 'validation on availability fires with not availability', ->
  #   delete @defaultData.availability
  #   v = new V.RequestFormView @viewData
  #   v.model.set @defaultData
  #   v.$('.save').click()
  #   expect( hlpr.showsError(v.$("[name=availability]")) ).to.be.true

  # it 'validation on brief fires with brief', ->
  #   delete @defaultData.brief
  #   v = new V.RequestFormView @viewData
  #   v.model.set @defaultData
  #   v.$('.save').click()
  #   expect( hlpr.showsError(v.$("[name=brief]")) ).to.be.true

  # it 'validation on tags fires with no tags', ->
  #   delete @defaultData.tags
  #   v = new V.RequestFormView @viewData
  #   v.model.set @defaultData
  #   v.$('.save').click()
  #   errorMSG = v.$('.controls-tags .error-message')
  #   expect(errorMSG.length).to.equal 1

  # it 'validation error goes away when a tag is chosen', ->
  #   delete @defaultData.tags
  #   v = new V.RequestFormView @viewData
  #   v.model.set @defaultData
  #   v.$('.save').click()
  #   expect( v.$('.controls-tags .error-message').length ).to.equal 1
  #   v.model.set 'tags', [data.tags[0]]
  #   expect( v.$('.controls-tags .error-message').length ).to.equal 0

  # it 'can select a tag', ->
  #   v = new V.RequestFormView @viewData
  #   v.tags.trigger 'sync'
  #   expect( v.$('.tt-dropdown-menu').is(':visible') ).to.be.false
  #   $('.autocomplete').val('c').trigger('input')
  #   expect( v.$('.tt-dropdown-menu').is(':visible') ).to.be.true
  #   expect( v.model.get('tags') ).to.equal undefined
  #   $('.tt-suggestion')[0].click()
  #   expect( v.model.get('tags').length ).to.equal 1
  #   expect( v.$('.selected .label-tag').length ).to.equal 1

  # it 'can remove a tag', ->
  #   v = new V.RequestFormView @viewData
  #   v.tags.trigger 'sync'
  #   $('.autocomplete').val('c').trigger('input')
  #   expect( v.model.get('tags') ).to.equal undefined
  #   $('.tt-suggestion')[0].click()
  #   $(v.$('.selected .label-tag')[0]).find('.rmTag').click()
  #   expect( v.model.get('tags').length ).to.equal 0
  #   $log '.selected .controls-tags', v.$('.label-tag')


  # it 'can add a new stackoverflow tag', (done) ->
  #   v = new V.RequestFormView @viewData
  #   v.tags.trigger 'sync'

  #   $('.autocomplete').val('zzzzzd').trigger('input').trigger('input')
  #   expect( v.$('.tt-suggestions .new').length ).to.equal 1
  #   newLink = $(v.$('.tt-suggestions .new')[0])
  #   expect( v.$('.autocomplete').is(':visible') ).to.be.true
  #   expect( v.$('#tagNewForm').is(':visible') ).to.be.false
  #   newLink.click()
  #   expect( v.$('.autocomplete').is(':visible') ).to.be.false
  #   expect( v.$('#tagNewForm').is(':visible') ).to.be.true
  #   expect( v.$('[name=nameStackoverflow]').val() ).to.equal 'zzzzzd'
  #   expect( v.model.get('tags') ).to.equal undefined
  #   v.$('[name=nameStackoverflow]').val('c')
  #   v.$('.save-so').click()

  #   tagSaved = =>
  #     expect( v.model.get('tags').length ).to.equal 1
  #     expect( v.model.get('tags')[0].short ).to.equal 'c'
  #     expect( v.$('.selected .label-tag').length ).to.equal 1
  #     expect( v.$('.autocomplete').is(':visible') ).to.be.true
  #     expect( v.$('#tagNewForm').is(':visible') ).to.be.false
  #     done()

  #   v.tags.once 'sync', tagSaved, @

  # it 'display error when trying to add invalid stackoverflow tag', (done) ->
  #   v = new V.RequestFormView @viewData
  #   v.tags.trigger 'sync'

  #   $('.autocomplete').val('zxxx').trigger('input').trigger('input')
  #   newLink = $(v.$('.tt-suggestions .new')[0])
  #   newLink.click()
  #   expect( v.model.get('tags') ).to.equal undefined
  #   v.$('.save-so').click()

  #   tagSavedFailed = =>
  #     $log 'tagSavedFailed'
  #     expect( v.model.get('tags').length ).to.equal 0
  #     expect( v.$('.selected .label-tag').length ).to.equal 0
  #     expect( v.$('.autocomplete').is(':visible') ).to.be.false
  #     expect( v.$('#tagNewForm').is(':visible') ).to.be.true
  #     done()

  #   v.tags.once 'sync', tagSavedFailed, @

#   # it 'on server error, error message renders', ->
#   #   expect(false).to.be.true
