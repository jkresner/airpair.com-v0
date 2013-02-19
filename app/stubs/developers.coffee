d = @stubs.dates
@stubs.developers = {}



aDev= (id, name, email, rate, gh, so, homepage, pic, skills) ->
  id:           id
  name:         name
  email:        email
  rate:         rate
  gh:           gh
  so:           so
  homepage:     homepage
  pic:          pic
  skills:       skills

@stubs.developers.jsdevs = [
  @jkresner = aDev 900001, 'Jonathon Kresner', 'jkresner@gmail.com', '$40p.h.', 'jkresner', '178211/jonathon-kresner', 'hackerpreneurialism.com', 'https://secure.gravatar.com/avatar/780d02a99798886da48711d8104801a4?s=420', [@backbone,@coffee,@brunch]
  @jcdavison = aDev 900002, 'John Davison', 'johncdavison@gmail.com', '-', 'jcdavison', '1345135/john', 'johncdavison.com', 'https://secure.gravatar.com/avatar/78edebd4f93a44265507e01170961309?s=420', [@ror]
  @focusaurus = aDev 900003, 'Peter Lyons', 'pete@peterlyons.com', '-', 'focusaurus', '266795/peter-lyons', 'peterlyons.com', 'https://secure.gravatar.com/avatar/3b59ae9a92deace346db01f415789f20?s=420', [@node,@javascript,@backbone,@coffee,@express,@bdd,@mocha]
  @jmontross = aDev 900004, 'Joshua Montross', 'joshua.montross@gmail.com', '-', 'jmontross', '602215/jmontross', 'pointmanj.com', 'https://secure.gravatar.com/avatar/b99d624363c48e67696a8d4176a11456?s=420', [@ror,@backbone,@chef,@ruby,@rubymotion,@ubuntu,@javascript,@php,@codeigniter]
  @gosuri = aDev 900005, 'Greg Osuri', 'gosuri@gmail.com', '-', 'gosuri', '228480/greg-osuri', 'gregosuri.com', 'https://secure.gravatar.com/avatar/9c6165b107059ea5dfa2e81985fe8272?s=420', [@ror,@backbone,@chef,@ruby,@java,@javascript,@c]
  @arieljake = aDev 900006, 'Ariel Jakobovits', 'arieljake@gmail.com', '-', 'arieljake', null, 'meetup.com/Bay-Area-Graph-Lab/members/4211752/', 'https://i2.wp.com/a248.e.akamai.net/assets.github.com/images/gravatars/gravatar-user-420.png', [@javascript]
]
