d = @stubs.dates
@stubs.developers = {}



aDev= (id, name, email, rate, gh, so, blog, skills) ->
  id:           id
  name:         name
  email:        email
  gh:           gh
  so:           so
  blog:         blog
  rate:         rate
  skills:       skills

@stubs.developers.jsdevs = [
  @jkresner = aDev 900001, 'Jonathon Kresner', 'jkresner@gmail.com', 'jkresner', '178211/jonathon-kresner', 'hackerpreneurialism.com', '$40p.h.', [@backbone,@coffee,@brunch]
  @jcdavison = aDev 900002, 'John Davison', 'johncdavison@gmail.com', 'jcdavison', '1345135/john', 'johncdavison.com', '-', [@ror]
  @focusaurus = aDev 900003, 'Peter Lyons', 'pete@peterlyons.com', 'focusaurus', '266795/peter-lyons', 'peterlyons.com', '-', [@node,@javascript,@backbone,@coffee,@express,@bdd,@mocha]
]
