{_,sinon,chai,expect} = require './../../test-lib-setup'
global._ = _
global.Backbone = require './../../../../vendor/scripts/backbone'
sm = require './../../../../app/scripts/shared/models'

describe "UI models shared", ->

  before ->
  after ->
  beforeEach ->

  it "tagsString returns empty string for null tags", ->
    m = new sm.Request()
    expect( m.tagsString() ).to.equal ''

  it "tagsString returns empty string for 0 length tags", ->
    m = new sm.Request tags: []
    expect( m.tagsString() ).to.equal ''

  it "tagsString returns single string for 1 length tags", ->
    m = new sm.Request tags: [{name:'backbone'}]
    expect( m.tagsString() ).to.equal 'backbone'

  it "tagsString returns and separated string for 1 length tags", ->
    m = new sm.Request tags: [{name:'backbone'},{name:'underscore'}]
    expect( m.tagsString() ).to.equal 'backbone and underscore'

  it "tagsString returns commma and and separated string for 1 length tags", ->
    m = new sm.Request tags: [{name:'backbone'},{name:'underscore'},{name:'node'}]
    expect( m.tagsString() ).to.equal 'backbone, underscore and node'

  it "tagsString returns commma and and separated string for 1 length tags", ->
    m = new sm.Request tags: [{name:'backbone'},{name:'underscore'},{name:'node'},{name:'mongo'}]
    expect( m.tagsString() ).to.equal 'backbone, underscore, node and mongo'