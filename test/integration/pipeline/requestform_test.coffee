M = require '/scripts/pipeline/Models'
C = require '/scripts/pipeline/Collections'
V = require '/scripts/pipeline/Views'

rI = -1
cloneReq = (id) ->
  r = _.clone(_.find data.inbound.requests, (r) -> r._id is id)
  delete r._id
  r

requests = [
  cloneReq '51c78eb587b25a0200000018'
  cloneReq '51c78eb587b25a0200000018'
  cloneReq '51c71ad46c50380200000006'
]

describe "Pipeline: RequestView", ->

  before (done) ->
    hlpr.setInitApp @, '/scripts/pipeline/Router'
    hlpr.setSession 'admin', done
  afterEach -> hlpr.cleanTearDown @
  beforeEach (done) ->
    rI++
    window.location = "#"
    hlpr.cleanSetup @, data.fixtures.inbound
    r = new M.Request()
    r.save requests[rI], success: (model) =>
      data.inbound.requests.push model.attributes
      initApp data.inbound
      @rID = model.id
      done()

  it 'request view does not save mail templates & tags string', (done) ->
    router.navTo "request/#{@rID}"
    router.app.selected.once 'sync', =>
      rv = router.app.requestView
      expect( requests[rI].company.mailTemplates ).to.equal undefined
      comp = rv.model.get('company')
      expect( comp.mailTemplates ).to.equal undefined
      done()

  it 'Can suggest expert with higher rate than budget ...', (done) ->
    rv = router.app.requestView
    router.navTo "request/#{@rID}"

    router.app.selected.once 'sync', =>
      expect( rv.$el.is(':visible') ).to.equal true
      expect( router.app.requestsView.$el.is(':visible') ).to.equal false
      expect( rv.model.get('suggested').length ).to.equal 0
      expect( rv.model.get('budget') ).to.equal 90
      # select the first tag and show its experts
      rv.$('#suggestions a').first().click()
      setTimeout suggestionsRendered, 100

    suggestionsRendered = =>
      amosSuggestion = rv.$('[data-id=519c2d3cb9ea8f0200000007]')
      amosSuggestion.click()
      rv.model.once 'sync', suggestionSynced

    suggestionSynced = =>
      expect( rv.model.get('suggested').length ).to.equal 1
      suggested1 = rv.model.get('suggested')[0]
      expect( suggested1._id ).to.not.equal undefined
      expect( suggested1.expert.rate ).to.equal 160
      expect( suggested1.suggestedRate.opensource.expert ).to.equal 70
      expect( suggested1.suggestedRate.opensource.total ).to.equal 90
      expect( rv.$('#suggested .suggested').length ).to.equal 1
      done()

  it 'Can suggest 2 expert(s) with matching & lower rates than budget ...', (done) ->
    rv = router.app.requestView
    router.navTo "request/#{@rID}"

    router.app.selected.once 'sync', =>
      # select the first tag and show its experts
      rv.$('#suggestions a').first().click()
      setTimeout suggestionsRendered, 100

    suggestionsRendered = ->
      expect( rv.model.get('suggested').length ).to.equal 0
      expect( rv.model.get('budget') ).to.equal 90

      richkuoSuggestion = rv.$('[data-id=51a4d2b47021eb0200000009]')
      richkuoSuggestion.click()

      requnixSuggestion = rv.$('[data-id=51a466707021eb0200000004]')
      requnixSuggestion.click()
      rv.model.on 'sync', suggestionsSynced

    suggestionsSynced = =>
      if rv.model.get('suggested').length == 1 then return
      expect( rv.model.get('suggested').length ).to.equal 2
      suggested2 = rv.model.get('suggested')[1]
      expect( suggested2.expert.rate ).to.equal 40
      expect( suggested2.suggestedRate.opensource.expert ).to.equal 49
      done()
