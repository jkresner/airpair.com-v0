M = require '/scripts/tags/Models'
C = require '/scripts/tags/Collections'
V = require '/scripts/tags/Views'

seedData = (cb) ->
  $.get '/seeddata', (data) -> cb()

unseedData = (cb) ->
  $.get '/seeddata', (data) -> cb()

describe "Tags: tag admin", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/tags/Router'
    seedData ->
      hlpr.setSession 'admin', done

  beforeEach (done) ->
    window.location = "#"
    hlpr.cleanSetup @, data.fixtures.tags
    initApp {}, done 
  
  afterEach ->
    hlpr.cleanTearDown @

  after ->
    unseedData ->

  it "can edit a tag as admin", (done) ->
    
    v = @app.tagsView
    @app.tags.once 'sync', =>

      m = v.collection.findWhere 
        name: 'c'

      # check the tag exists
      expect( m.get 'name' ).to.equal 'c'

      # expand the tag and verify the div contains the form
      v.$('[href="#tag/' + m.id + '"]').click()
      d = $('[href="#tag/' + m.id + '"]').parent()
      expect(d.is(':visible')).to.equal true

      # update all the fields of the form
      test_name = 'new name'
      test_short = 'new short name'
      test_desc = 'new desc'
      test_stackid = 'new stackid'
      test_githubid = 'new githubid'
      test_tokens = 'new tokens'

      form = $(d, 'div')
      $('input[name=name]', form).val(test_name)
      $('input[name=short]', form).val(test_short)
      $('input[name=desc]', form).val(test_desc)
      $('input[name=soId]', form).val(test_stackid)
      $('input[name=ghId]', form).val(test_githubid)
      $('input[name=tokens]', form).val(test_tokens)

      m.on 'sync', (m) ->
        expect( m.get 'name' ).to.equal test_name
        expect( m.get 'short' ).to.equal test_short
        expect( m.get 'desc' ).to.equal test_desc
        expect( m.get 'soId' ).to.equal test_stackid
        expect( m.get 'ghId' ).to.equal test_githubid             
        expect( m.get 'tokens' ).to.equal test_tokens
        done()

      $('a.btn-success', form).click()
      # done is called inside m.on (sync)
