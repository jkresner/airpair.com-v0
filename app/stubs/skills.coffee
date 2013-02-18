
aSkill = (id, name, shortName, soId) ->
  id:           id
  name:         name
  shortName:    shortName
  soId:         soId

@stubs.skills = [
  @backbone = aSkill 25016, 'Backbone.js', 'backbone', 'backbone.js'
  @bdd = aSkill 25036, 'Behavior Driven Development', 'bdd', 'bdd'
  @brunch = aSkill 25096, 'Brunch.io', 'brunch', 'brunch'
  @coffee = aSkill 30136, 'CoffeeScript', 'coffee', 'coffeescript'
  @crawler = aSkill 30036, 'Crawler', 'crawler', 'crawler'
  @express = aSkill 32231, 'ExpressJS', 'express', 'express'
  @mocha = aSkill 34231, 'Mocha', 'mocha', 'mocha'
  @node = aSkill 35231, 'NodeJS', 'node', 'node.js'
  @ror = aSkill 37231, 'Ruby on Rails', 'ror', 'ruby-on-rail'
  @jasmine = aSkill 39211, 'Jasmine', 'jasmine', 'jasmine'
  @javascript = aSkill 39231, 'JavaScript', 'js', 'javascript'
  @windows = aSkill 45236, 'Windows', 'win', 'windows'
]