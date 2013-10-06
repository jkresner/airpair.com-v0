M = require '/scripts/review/Models'
C = require '/scripts/review/Collections'
V = require '/scripts/review/Views'


describe "Review: book", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/review/Router'
    hlpr.setSession 'emilLee', =>
      $.post('/api/requests',data.requests[8]).done (r) =>
        $.get("/api/requests/#{r._id}").done (r) =>
          @r = r
          done()

  beforeEach ->
    window.location = "#"+@r._id
    hlpr.cleanSetup @, data.fixtures.review
    initApp session: data.users[6], request: @r

  afterEach ->
    hlpr.cleanTearDown @

  it "can book expert hours as customer", (done) ->
    rv = @app.requestView
    bv = @app.bookView
    req = rv.request

    expect( rv.$el.is(':visible') ).to.equal true
    expect( bv.$el.is(':visible') ).to.equal false
    expect( req.get('suggested')[0].expertStatus ).to.equal 'abstained'
    expect( req.get('suggested')[1].expertStatus ).to.equal 'waiting'
    expect( req.get('suggested')[2].expertStatus ).to.equal 'available'
    expect( req.get('suggested')[2].expert.username ).to.equal 'richkuo'
    # 10/6/13 No longer showing waiting experts so only will be in suggestion view
    expect( rv.$('.suggested .suggestion').length ).to.equal 2
    expect( rv.$('.book-actions').is(':visible') ).to.equal true

    expect( rv.$('.book-actions .btn').attr('href') ).to.equal "#book/#{@r._id}"

    router.navTo "#book/#{@r._id}"
    expect( rv.$el.is(':visible') ).to.equal false
    expect( bv.$el.is(':visible') ).to.equal true

    expect( bv.$('#bookableExperts .bookableExpert').length ).to.equal 1
    $kuo = $(bv.$('#bookableExperts .bookableExpert')[0])
    expect( $kuo.find('.username').html() ).to.equal '@richkuo'
    expect( $kuo.find('.total').html() ).to.equal '0'
    expect( $kuo.find('.unitPrice').html() ).to.equal '60'
    expect( $kuo.find('.qty').html() ).to.equal '0'

    $kuo.find('[name=qty]').val('2').trigger('change')
    expect( $kuo.find('.total').html() ).to.equal '120'
    expect( $kuo.find('.unitPrice').html() ).to.equal '60'
    expect( $kuo.find('.qty').html() ).to.equal '2'

    $kuo.find('[name=type]').val('private').trigger('change')
    expect( $kuo.find('.total').html() ).to.equal '160'
    expect( $kuo.find('.unitPrice').html() ).to.equal '80'
    expect( $kuo.find('.qty').html() ).to.equal '2'

    bv.model.once 'sync', =>
      m = bv.model
      # $log 'synced'
      expect( m.get('requestId') ).to.equal req.id
      expect( m.get('total') ).to.equal 160
      expect( m.get('lineItems').length ).to.equal 1
      done()

    bv.$('.pay').click()

