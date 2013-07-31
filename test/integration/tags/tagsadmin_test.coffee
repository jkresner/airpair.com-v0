M = require '/scripts/tags/Models'
C = require '/scripts/tags/Collections'
V = require '/scripts/tags/Views'

seedTagData = (cb) ->
  $.get '/seeddata', (data) -> cb()

unseedTagData = (cb) ->
  $.get '/unseeddata', (data) -> cb()

describe "Tags: tag admin", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/tags/Router'
    hlpr.setSession 'admin', ->
      seedTagData done

  beforeEach (done) ->
    window.location = "#"
    hlpr.cleanSetup @, data.fixtures.tags
    initApp {}, done 
  
  afterEach ->
    hlpr.cleanTearDown @

  after (done) ->
    unseedTagData done

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
        expect( m.get 'tokens' ).to.equal test_tokens

        # we don't want to save so and gh on form submit
        expect( m.get 'soId' ).to.not.equal test_stackid
        expect( m.get 'ghId' ).to.not.equal test_githubid             

        done()

      $('a.btn-success', form).click()
      # done is called inside m.on (sync)

  it "can get github data for existing tag", (done) ->

    v = @app.tagsView
    @app.tags.once 'sync', =>

      m = v.collection.findWhere 
        name: 'c++'

      # check the tag exists
      expect( m.get 'name' ).to.equal 'c++'

      # expand the tag and verify the div contains the form
      v.$('[href="#tag/' + m.id + '"]').click()
      d = $('[href="#tag/' + m.id + '"]').parent()
      expect(d.is(':visible')).to.equal true

      # set the github project to bootstrap
      test_githubid = 'twbs/bootstrap'

      form = $(d, 'div')
      #$('input[name=nameGithub]', form).val(test_githubid)
      $('input[name=ghId]', form).val(test_githubid)

      m.on 'sync', (m) ->
        expect( m.get 'ghId' ).to.equal test_githubid
        expect( m.get('gh').id).to.equal 2126244
        expect( m.get('gh').name).to.equal 'bootstrap'
        expect( m.get('gh').full).to.equal test_githubid
        expect( m.get('gh').watchers).to.be.above 50000
        expect( m.get('gh').language).to.equal 'CSS'
        expect( m.get('gh').owner).to.deep.equal
          avatar: 'https://secure.gravatar.com/avatar/025073862721c9b5af4a0269eabecb8e?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-org-420.png'
          url: 'https://api.github.com/users/twbs'
          login: 'twbs'
          id: 2918581

        done()

      $('.fetchGH', form).click()
      # done is called inside m.on (sync)

  it "can not create tag with the same github ids", (done) -> 
    v = @app.tagsView
    @app.tags.once 'sync', =>

      m = v.collection.findWhere 
        name: 'netty'

      # check the tag exists
      expect( m.get 'name' ).to.equal 'netty'

      # expand the form
      v.$('[href="#tag/' + m.id + '"]').click()

      # set the github project to bootstrap
      d = $('[href="#tag/' + m.id + '"]').parent()
      form = $(d, 'div')
      test_githubid = 'twbs/bootstrap'      
      $('input[name=ghId]', form).val(test_githubid)

      tagSaveFailed = =>
        expect( v.$('.alert-error').text() ).to.equal 'E11000 duplicate key error index: airpair_test.tags.$ghId_1  dup key: { : "twbs/bootstrap" }'        
        done()

      m.once 'error', tagSaveFailed, @

      $('.fetchGH', form).click()

  it "can not create tag with less than 20 watchers", (done) ->
    v = @app.tagsView
    @app.tags.once 'sync', =>

      m = v.collection.findWhere 
        name: 'netty'

      # check the tag exists
      expect( m.get 'name' ).to.equal 'netty'

      v.$('[href="#tag/' + m.id + '"]').click()

      # set the github project to one w under 20 watchers
      d = $('[href="#tag/' + m.id + '"]').parent()
      form = $(d, 'div')
      test_githubid = 'Genability/genability-java'
      $('input[name=ghId]', form).val(test_githubid)

      tagSaveFailed = =>
        expect( v.$('.alert-error').text() ).to.equal 'Can not add ' + test_githubid + ' as it has less than 20 watchers.'
        done()

      m.once 'error', tagSaveFailed, @

      $('.fetchGH', form).click()

  it "does not save github id if project not found", (done) ->
    v = @app.tagsView
    @app.tags.once 'sync', =>

      m = v.collection.findWhere 
        name: 'typeahead.js'

      # check the tag exists
      expect( m.get 'name' ).to.equal 'typeahead.js'

      v.$('[href="#tag/' + m.id + '"]').click()

      # set the github project to an invalid one
      d = $('[href="#tag/' + m.id + '"]').parent()
      form = $(d, 'div')
      test_githubid = 'asdf/wxyz'
      $('input[name=ghId]', form).val(test_githubid)

      tagSaveFailed = =>
        expect( v.$('.alert-error').text() ).to.equal 'tag ' + test_githubid + ' not found'
        done()

      m.once 'error', tagSaveFailed, @

      $('.fetchGH', form).click()