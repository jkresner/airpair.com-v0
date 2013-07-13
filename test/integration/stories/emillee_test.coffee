Tags = require('/scripts/request/Collections').Tags
f = data.fixtures

storySteps = [
  { appName:'request', usr:'emilLee', frag: '#', fixture: f.request }
  { appName:'dashboard', usr:'emilLee', frag: '#', fixture: f.dashboard }
  { appName:'review', usr:'emilLee', frag: '#rId', fixture: f.review }
  { appName:'request', usr:'emilLee', frag: '#edit/rId', fixture: f.request }
  { appName:'review', usr:'anon', frag: '#rId', fixture: f.review }
  { appName:'inbound', usr:'jk', frag: '#', fixture: f.inbound }
  { appName:'review', usr:'richkuo', frag: '#rId', fixture: f.review }
  { appName:'review', usr:'mattvanhorn', frag: '#rId', fixture: f.review }
  { appName:'review', usr:'emilLee', frag: '#rId', fixture: f.review }
  { appName:'inbound', usr:'jk', frag: '#', fixture: f.inbound }
  { appName:'inbound', usr:'jk', frag: '#', fixture: f.inbound }
  { appName:'feedback', usr:'mattvanhorn', frag: '#', fixture: f.feedback }
  { appName:'feedback', usr:'emilLee', frag: '#', fixture: f.feedback }
]

testNum = -1

describe "Stories: Emil Lee", ->

  before (done) ->
    @tagsFetch = sinon.stub Tags::, 'fetch', -> @set data.tags; @trigger 'sync'
    done()

  beforeEach (done) ->
    testNum++
    hlpr.cleanSetup @, storySteps[testNum].fixture
    window.location = storySteps[testNum].frag.replace 'rId', @rId
    hlpr.setInitApp @, "/scripts/#{storySteps[testNum].appName}/Router"
    hlpr.setSession storySteps[testNum].usr, =>
      initApp({}, done)

  afterEach ->
    hlpr.cleanTearDown @


  it 'can create request by customer', (done) ->
    {infoFormView,requestFormView} = @app
    @app.company.once 'sync', =>
      infoFormView.elm('name').val 'WPack'
      infoFormView.elm('url').val ''
      infoFormView.elm('about').val 'Looking to build a professional networking website that helps users continuously accomplish their professional goals. For example, mutual introductions through connections.'

      @app.company.once 'sync', =>
        requestFormView.$('.autocomplete').val('ruby').trigger('input')
        $(requestFormView.$('.tt-suggestion')[0]).click()
        requestFormView.elm('brief').val 'I want help firstly with CSS / design. I will ask for assistance with building a "business card" online (using HTML / CSS), and then also a profile. After that, would like help building the front end interaction (JS/AJAX) and back end (rails/postgres).'
        requestFormView.$('#pricingOpensource').click()
        requestFormView.$('#budget1').click()
        requestFormView.elm('availability').val('New York. Available after business hours on weekdays, any time weekends.')

        @app.request.once 'sync', =>
          @rId = @app.request.id
          done()

        requestFormView.$('.save').click()
      infoFormView.$('.save').click()

  it 'can see request in dashboard by customer', (done) ->
    {requestsView} = @app
    @app.requests.once 'sync', =>
      $row = requestsView.$("##{@rId}")
      expect($row.find('.label-received').html()).to.equal 'received'
      expect($row.find('.btn-info').attr('href')).to.equal "/review/#{@rId}"
      expect($row.find('.edit').attr('href')).to.equal "/find-an-expert/edit/#{@rId}"
      done()

  it 'can review request with no experts by customer', (done) ->
    {request,requestView} = @app
    v = requestView

    request.once 'change', =>
      expect( v.$('.brief').html() ).to.equal request.get('brief')
      expect( v.$('#noExpertsYet').html() ).to.equal 'Experts not yet suggested ... '
      expect( v.$('.book-actions').is(':visible') ).to.equal false
      expect( v.$('.budget').is(':visible') ).to.equal true

      done()

  it 'can update request by customer', (done) ->
    {infoFormView,requestFormView,company} = @app
    v = requestFormView
    company.once 'sync', =>
      company.once 'sync', =>
        expect( v.$el.is(':visible') ).to.equal true
        v.$('.autocomplete').val('c++').trigger('input')
        $(v.$('.tt-suggestion')[0]).click()
        expect( v.mget('tags').length ).to.equal 2
        v.elm('brief').val 'I want help firstly with CSS / design. I will ask for assistance with building a "business card" online (using HTML / CSS), and then also a profile. After that, would like help building the front end interaction (JS/AJAX) and back end (rails/postgres).'
        v.$('#pricingPrivate').click()
        v.$('#budget2').click()
        v.elm('availability').val('New York. Available after business hours on weekdays, any time weekends.')

        @app.request.once 'sync', (model, resp, opts) =>
          # $log 'model', model.attributes
          expect( model.get('budget') ).to.equal 110
          expect( model.get('pricing') ).to.equal 'private'
          expect( model.get('tags').length ).to.equal 2
          done()

        requestFormView.$('.save').click()
      infoFormView.$('.save').click()

  it 'can review request as anonymous', (done) ->
    {request,requestView} = @app
    v = requestView

    request.once 'change', =>
      expect( v.$('.budget').is(':visible') ).to.equal false
      expect( v.$('.brief').html() ).to.equal request.get('brief')
      expect( v.$('.book-actions').is(':visible') ).to.equal false
      expect( v.$('#notExpertOrCustomer').is(':visible') ).to.equal true
      expect( v.$('#signin').is(':visible') ).to.equal true
      done()

  # it 'can suggest experts as admin', (done) ->
  #   done()

  # it 'can review request and accept request as expert', (done) ->
  #   done()

  # it 'can review request and decline request as expert', (done) ->
  #   done()

  # it 'can review experts and book hours as customer', (done) ->
  #   done()

  # it 'can schedule call as admin', (done) ->
  #   done()

  # it 'can save call url as admin', (done) ->
  #   # can send how was email?
  #   done()

  # it 'can leave feedback on call as customer', (done) ->
  #   # can send how was email?
  #   done()

  # it 'can leave feedback on call as expert', (done) ->
  #   # can send how was email?
  #   done()