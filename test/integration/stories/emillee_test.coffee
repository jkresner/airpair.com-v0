Tags = require('/scripts/ap/request/Collections').Tags
f    = data.fixtures

storySteps = [
  { app:'ap/request', usr:'emilLee', frag: '#', fixture: f.request, pageData: {} }
  { app:'ap/dashboard', usr:'emilLee', frag: '#', fixture: f.dashboard, pageData: {} }
  { app:'ap/review', usr:'emilLee', frag: '#rId', fixture: f.review, pageData: {} }
  { app:'ap/request', usr:'emilLee', frag: '#edit/rId', fixture: f.request, pageData: {} }
  { app:'ap/review', usr:'anon', frag: '#rId', fixture: f.review, pageData: {} }
  { app:'adm/pipeline', usr:'admin', frag: '#', fixture: f.inbound, pageData: { experts: data.experts, tags: data.tags } }
  { app:'ap/review', usr:'richkuo', frag: '#rId', fixture: f.review, pageData: {} }
  { app:'ap/review', usr:'mattvanhorn', frag: '#rId', fixture: f.review, pageData: {} }
  { app:'ap/review', usr:'emilLee', frag: '#rId', fixture: f.review, pageData: {} }
  { app:'adm/pipeline', usr:'jk', frag: '#', fixture: f.inbound, pageData: {} }
  { app:'adm/pipeline', usr:'jk', frag: '#', fixture: f.inbound, pageData: {} }
  { app:'ap/feedback', usr:'mattvanhorn', frag: '#', fixture: f.feedback, pageData: {} }
  { app:'ap/feedback', usr:'emilLee', frag: '#', fixture: f.feedback, pageData: {} }
]

testNum = -1

describe "Stories: Emil Lee", ->

  before (done) ->
    @tagsFetch = sinon.stub Tags::, 'fetch', -> @set data.tags; @trigger 'sync'
    done()

  after -> @tagsFetch.restore()

  beforeEach (done) ->
    testNum++
    hlpr.cleanSetup @, storySteps[testNum].fixture
    window.location = storySteps[testNum].frag.replace 'rId', @rId
    hlpr.setInitApp @, "/scripts/#{storySteps[testNum].app}/Router"
    hlpr.setSession storySteps[testNum].usr, =>
      # $log 'app', storySteps[testNum].app, storySteps[testNum].pageData
      initApp(storySteps[testNum].pageData, done)

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
      expect( v.$('.brief').text().trim()).to.equal request.get('brief')
      # expect( v.$('#noExpertsYet').html() ).to.equal 'Experts not yet suggested ... '
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
      expect( v.$('.brief').text().trim() ).to.equal request.get('brief')
      expect( v.$('.book-actions').is(':visible') ).to.equal false
      expect( v.$('#notExpertOrCustomer').is(':visible') ).to.equal true
      # expect( v.$('#signin').is(':visible') ).to.equal true
      done()

  it 'can suggest experts as admin', (done) ->
    rv = @app.requestView

    # makes sure that requests do load.
    @app.requests.once 'sync', =>
      router.navTo "#request/#{@rId}"

    # now we're on the request page, and have the data.
    @app.selected.once 'sync', =>
      expect( rv.$el.is(':visible') ).to.equal true
      # select the first tag and show its experts
      rv.$('#suggestions a').first().click()
      setTimeout rest, 100

    rest = ->
      richkuo = rv.$('[data-id=51a4d2b47021eb0200000009]') # Richard Kuo
      reQunix = rv.$('[data-id=51a466707021eb0200000004]') # Michael Prins
      mattvanhorn = rv.$('[data-id=51b0c417900c860200000018]') # Matthew Van Horn

      rv.model.on 'sync', =>
        # times out with an error if this were to fail
        expect()
        if rv.mget('suggested').length is 3
          expect( rv.mget('suggested').length ).to.equal 3
          expect( rv.mget('suggested')[0].expert._id ).to.equal '51a4d2b47021eb0200000009'
          expect( rv.mget('suggested')[1].expert._id ).to.equal '51a466707021eb0200000004'
          expect( rv.mget('suggested')[2].expert._id ).to.equal '51b0c417900c860200000018'
          done()
      richkuo.click()
      reQunix.click()
      mattvanhorn.click()

  it 'can review request and accept request as expert richkuo', (done) ->
    v = @app.requestView
    v.request.once 'change', =>
      expect( v.$('.book-actions').is(':visible') ).to.equal false

      v.elm('agree').click()
      v.elm('payPalEmail').val 'expert02@airpair.com'

      v.elm('expertRating').val 5
      v.elm('expertFeedback').val 'My skillset: Back end - Ruby developer with experience using Rails and Sinatra. Front end - Experience with JS, JQuery, and front end frameworks. Design - Experience with Photoshop, CSS, SCSS, Bootstrap, Foundation, UI/UX design. Business - Sales, marketing, product, strategy, data analysis.'
      v.elm('expertStatus').val('available').trigger 'change'
      v.elm('expertComment').val 'This looks great'
      v.elm('expertAvailability').val 'New York. Available after business hours on weekdays, any time weekends. Eastern time.'

      v.expertReviewView.model.once 'sync', (m,res,ops) =>
        expect( m.get('suggested')[0].expert.username ).to.equal 'richkuo'
        expect( m.get('suggested')[0].expertStatus ).to.equal 'available'
        expect( m.get('suggested')[0].expertComment ).to.equal 'This looks great'
        done()

      v.$('.saveFeedback').click()


  it 'can review request and decline request as expert', (done) ->
    v = @app.requestView
    v.request.once 'change', =>
      expect( v.$('.book-actions').is(':visible') ).to.equal false
      v.elm('expertRating').val 2
      v.elm('expertFeedback').val "It seems like you need someone whose strength is more on the visual/UX design side, at least to start out. Happy to work with you when you're ready to move on to writing code."
      v.elm('expertStatus').val('abstained').trigger 'change'
      v.elm('expertComment').val 'Nups'
      v.elm('expertAvailability').val 'Unavailable'

      v.expertReviewView.model.once 'sync', =>
        m = v.request
        expect( m.get('suggested')[2].expert.username ).to.equal 'mattvanhorn'
        expect( m.get('suggested')[2].expertStatus ).to.equal 'abstained'
        expect( m.get('suggested')[2].expertComment ).to.equal 'Nups'

      v.$('.saveFeedback').click()

      done()

  it 'can review experts and book hours as customer', (done) ->
    {request,requestView} = @app
    v = requestView

    request.once 'change', =>
      expect( v.$('.brief').text().trim() ).to.equal request.get('brief')
      expect( v.$('.suggested .suggestion').length ).to.equal 1
      expect( v.$('.book-actions').is(':visible') ).to.equal true

      v.$('.book-actions .btn').click()

      # To be continued!

      done()


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
