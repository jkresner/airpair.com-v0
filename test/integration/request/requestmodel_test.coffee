M = require '/scripts/ap/request/Models'

describe 'Request:Model =>', ->

  before ->
  afterEach ->
  beforeEach ->
    @m = new M.Request()
    # @tags = new C.Tags( data.tags )

  it 'default pricing is private', ->
    expect( @m.get('pricing') ).to.equal 'private'

  it 'default rates is [80,110,150,210,300]', ->
    expect( @m.rates()).to.deep.equal [80,110,150,210,300]

  it 'default budget is 110', ->
    expect( @m.get('budget') ).to.equal 110

  it 'opensource rates is [60,90,130,180,250]', ->
    @m.set('pricing','opensource')
    expect( @m.rates()).to.deep.equal [60,90,130,190,280]

  it 'nda rates is [130,160,200,260,350]', ->
    @m.set('pricing','nda')
    expect( @m.rates()).to.deep.equal [130,160,200,260,350]
