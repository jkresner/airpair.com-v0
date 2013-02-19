
aSkill = (id, name, shortName, soId) ->
  id:           id
  name:         name
  shortName:    shortName
  soId:         soId

@stubs.skills = [
  @backbone = aSkill 25016, 'Backbone.js', 'backbone', 'backbone.js'
  @bdd = aSkill 25036, 'Behavior Driven Development', 'bdd', 'bdd'
  @brunch = aSkill 25096, 'Brunch.io', 'brunch', 'brunch'
  @c = aSkill 30016, 'C', 'c', 'c'
  @csharp = aSkill 30016, 'C#', 'c#', 'c#'
  @chef = aSkill 30116, 'Chef', 'chef', 'chef'
  @codeigniter = aSkill 30126, 'CodeIgniter', 'codeigniter', 'codeigniter'
  @coffee = aSkill 30136, 'CoffeeScript', 'coffee', 'coffeescript'
  @crawler = aSkill 30036, 'Crawler', 'crawler', 'crawler'
  @express = aSkill 32231, 'ExpressJS', 'express', 'express'
  @mocha = aSkill 34231, 'Mocha', 'mocha', 'mocha'
  @node = aSkill 35231, 'NodeJS', 'node', 'node.js'
  @ror = aSkill 37231, 'Ruby on Rails', 'ror', 'ruby-on-rails'
  @ruby = aSkill 37231, 'Ruby', 'rubymotion', 'rubymotion'
  @rubymotion = aSkill 37231, 'Ruby Motion', 'ruby', 'ruby'
  @jasmine = aSkill 39211, 'Jasmine', 'jasmine', 'jasmine'
  @java = aSkill 39221, 'Java', 'java', 'java'
  @javascript = aSkill 39231, 'JavaScript', 'js', 'javascript'
  @php = aSkill 44236, 'PHP', 'php', 'php'
  @ubuntu = aSkill 44236, 'Ubuntu', 'ubuntu', 'ubuntu'
  @windows = aSkill 45236, 'Windows', 'win', 'windows'
]



