# # docs on expect syntax                         chaijs.com/api/bdd/
# # docs on using spy/fake/stub                   sinonjs.org/docs/
# # docs on sinon chai syntax                     chaijs.com/plugins/sinon-chai
# {_, $, $log, Backbone} = window
# hlpr = require './../../test-ui-helper'
# # BB = require 'lib/BB'
# M = require 'scripts/beexpert/Models'
# C = require 'scripts/beexpert/Collections'
# V = require 'scripts/beexpert/Views'
# data =
#   experts: require './../../data/experts'
#   tags: require './../../data/tags'

# describe 'BeExpert:Views InfoFormView =>', ->

#   before -> $log 'BeExpert:Views InfoFormView'

#   beforeEach ->
#     hlpr.clean_setup @
#     hlpr.set_htmlfixture '<div id="infoForm"></div>'
#     @defaultData = homepage: 'http://home.co', brief: 'test', rate: 40, status: 'busy', hours: '3-5'
#     @expert = new M.Expert()
#     @tags = new C.Tags( data.tags )
#     @viewData = model: @expert, tags: @tags

#   afterEach ->
#     hlpr.clean_tear_down @

#   it 'on load sets correct homepage, hours, rate & status selected', ->
#     view = new V.InfoFormView @viewData
#     view.model.set @defaultData
#     expect( view.$('#homepage').val() ).to.be.equal 'http://home.co'
#     expect( view.$('[name=hours]').val() ).to.equal '3-5'
#     expect( view.$('#rate40').is(':checked') ).to.be.true
#     expect( view.$('#rate40').prev().hasClass('checked') ).to.be.true
#     expect( view.$('#statusBusy').is(':checked') ).to.be.true
#     expect( view.$('#statusBusy').prev().hasClass('checked') ).to.be.true


#   it 'strips http:// & https:// from websites & urls', ->


#   it 'validation on brief fires with brief', ->
#     delete @defaultData.brief
#     view = new V.InfoFormView @viewData
#     view.model.set @defaultData
#     view.$('.save').click()
#     errorMSG = view.$('.controls-brief .error-message')
#     expect(errorMSG.length).to.equal 1

#   it 'validation on tags fires with no tags', ->
#     delete @defaultData.tags
#     view = new V.InfoFormView @viewData
#     view.model.set @defaultData
#     view.$('.save').click()
#     errorMSG = view.$('.controls-tags .error-message')
#     expect(errorMSG.length).to.equal 1