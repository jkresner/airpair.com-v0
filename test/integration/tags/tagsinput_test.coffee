# docs on expect syntax                         chaijs.com/api/bdd/
# docs on using spy/fake/stub                   sinonjs.org/docs/
# docs on sinon chai syntax                     chaijs.com/plugins/sinon-chai
{_, $, $log, Backbone} = window

describe "tags input", ->

  it 'add new tag hides autocomplete', ->

  it 'add new tag re-uses value from autocomplete input', ->

  it 'after add new tag, can search for new tag', ->

  it 'displays error when tag not found', ->
    assert( false ).to.equal true

  it 'displays error when github repo has less than 20 stars', ->
    assert( false ).to.equal true

  it 'autocomplete gives results for sting matching', ->
    assert( false ).to.equal true

  it 'added tag is visible in tags list', ->