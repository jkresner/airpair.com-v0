# # docs on expect syntax                         chaijs.com/api/bdd/
# # docs on using spy/fake/stub                   sinonjs.org/docs/
# # docs on sinon chai syntax                     chaijs.com/plugins/sinon-chai
# {_, $, $log, Backbone} = window
# hlpr = require './../../test-ui-helper'
# # BB = require 'lib/BB'
# M = require 'scripts/request/Models'
# C = require 'scripts/request/Collections'
# V = require 'scripts/request/Views'
# data =
#   requests: require './../../data/requests'
#   tags: require './../../data/tags'

# describe 'Request:Views RequestFormView =>', ->

#   before -> $log 'Request:Views RequestFormView'

#   beforeEach ->
#     hlpr.clean_setup @
#     hlpr.set_htmlfixture '<div id="requestForm"></div>'
#     @defaultData = brief: 'test', availability: [new Date().toString()], budget: 30, pricing: 'private', hours: '1'
#     @request = new M.Request()
#     @tags = new C.Tags( data.tags )
#     @viewData = model: @request, tags: @tags

#   afterEach ->
#     hlpr.clean_tear_down @

#   it 'on load sets correct budget, pricing & hours radios', ->
#     view = new V.RequestFormView @viewData
#     view.model.set @defaultData
#     expect( view.$('#budget30').is(':checked') ).to.be.true
#     expect( view.$('#budget30').prev().hasClass('checked') ).to.be.true
#     expect( view.$('#pricingPrivate').is(':checked') ).to.be.true
#     expect( view.$('#pricingPrivate').prev().hasClass('checked') ).to.be.true
#     expect( view.$('[name=hours]').val() ).to.equal '1'

#   it 'validation on availability fires with not availability', ->
#     delete @defaultData.availability
#     view = new V.RequestFormView @viewData
#     view.model.set @defaultData
#     view.$('.save').click()
#     errorMSG = view.$('.controls-availability .error-message')
#     expect(errorMSG.length).to.equal 1

#   it 'validation on brief fires with brief', ->
#     delete @defaultData.brief
#     view = new V.RequestFormView @viewData
#     view.model.set @defaultData
#     view.$('.save').click()
#     errorMSG = view.$('.controls-brief .error-message')
#     expect(errorMSG.length).to.equal 1

#   it 'validation on tags fires with no tags', ->
#     delete @defaultData.tags
#     view = new V.RequestFormView @viewData
#     view.model.set @defaultData
#     view.$('.save').click()
#     errorMSG = view.$('.controls-tags .error-message')
#     expect(errorMSG.length).to.equal 1

#   it 'validation error goes away when a tag is chosen', ->
#     delete @defaultData.tags
#     view = new V.RequestFormView @viewData
#     view.model.set @defaultData
#     view.$('.save').click()
#     expect( view.$('.controls-tags .error-message').length ).to.equal 1
#     view.model.set 'tags', [data.tags[0]]
#     expect( view.$('.controls-tags .error-message').length ).to.equal 0


#   # it 'select time clears after a time is selected', ->
#   #   expect(false).to.be.true

#   # it 'selected time matches choice from input & is rounded to half hour', ->
#   #   expect(false).to.be.true

#   # it 'selected time does not wipe other selected form values', ->
#   #   # select hours
#   #   # select time
#   #   # confirm hours choice persists
#   #   expect(false).to.be.true

#   # it 'required error disappears after a time is selected', ->
#   #   expect(false).to.be.true

#   # it 'on server error, error message renders', ->
#   #   expect(false).to.be.true
