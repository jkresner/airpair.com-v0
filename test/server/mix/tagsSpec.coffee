{_,sinon,chai,expect} = require './../test-lib-setup'
{tagsString}           = require './../../../lib/mix/tags'

describe "UI models shared", ->

  it "tagsString returns empty string for null tags", ->
    expect( tagsString() ).to.equal ''

  it "tagsString returns empty string for 0 length tags", ->
    expect( tagsString([]) ).to.equal ''

  it "tagsString returns single string for 1 length tags", ->
    expect( tagsString([{name:'backbone'}]) ).to.equal '{backbone}'

  it "tagsString returns and separated string for 1 length tags", ->
    tags = [{name:'backbone'},{name:'underscore'}]
    expect( tagsString(tags) ).to.equal '{backbone} and {underscore}'

  it "tagsString returns commma and and separated string for 1 length tags", ->
    tags= [{name:'backbone'},{name:'underscore'},{name:'node'}]
    expect( tagsString(tags) ).to.equal '{backbone} {underscore} and {node}'

  it "tagsString returns commma and and separated string for 1 length tags", ->
    tags = [{name:'backbone'},{name:'underscore'},{name:'node'},{name:'mongo'}]
    expect( tagsString(tags) ).to.equal '{backbone} {underscore} {node} and {mongo}'
