d = @stubs.dates
@stubs.developers = {}

idCount = 1

aDev= (name, email, rate, gh, so, homepage, pic, other, skills) ->
  id:           idCount++
  name:         name
  email:        email
  rate:         rate
  gh:           gh
  so:           so
  homepage:     homepage
  pic:          pic
  other:        other
  skills:       skills

gravatarUrl = 'https://secure.gravatar.com/avatar/'
noAvatarUrl = 'https://i2.wp.com/a248.e.akamai.net/assets.github.com/images/gravatars/gravatar-user-420.png'

@stubs.developers.jsdevs = [
  @jkresner = aDev 'Jonathon Kresner', 'jkresner@gmail.com', '$40p.h.', 'jkresner', '178211/jonathon-kresner', 'hackerpreneurialism.com', gravatarUrl+'780d02a99798886da48711d8104801a4?s=420', null, [@backbone,@coffee,@brunch]
  @jcdavison = aDev 'John Davison', 'johncdavison@gmail.com', '-', 'jcdavison', '1345135/john', 'johncdavison.com', gravatarUrl+'78edebd4f93a44265507e01170961309?s=420', null, [@ror]
  @focusaurus = aDev 'Peter Lyons', 'pete@peterlyons.com', '-', 'focusaurus', '266795/peter-lyons', 'peterlyons.com', gravatarUrl+'3b59ae9a92deace346db01f415789f20?s=420', null, [@node,@javascript,@backbone,@coffee,@express,@bdd,@mocha]
  @jmontross = aDev 'Joshua Montross', 'joshua.montross@gmail.com', '-', 'jmontross', '602215/jmontross', 'pointmanj.com', gravatarUrl+'b99d624363c48e67696a8d4176a11456?s=420', null, [@ror,@backbone,@chef,@ruby,@rubymotion,@ubuntu,@javascript,@php,@codeigniter]
  @gosuri = aDev 'Greg Osuri', 'gosuri@gmail.com', '-', 'gosuri', '228480/greg-osuri', 'gregosuri.com', gravatarUrl+'9c6165b107059ea5dfa2e81985fe8272?s=420', null, [@ror,@backbone,@chef,@ruby,@java,@javascript,@c]
  @arieljake = aDev 'Ariel Jakobovits', 'arieljake@gmail.com', '-', 'arieljake', null, 'meetup.com/Bay-Area-Graph-Lab/members/4211752/', noAvatarUrl, null, [@javascript]
  @paulmillr = aDev 'Paul Miller', 'paul@paulmillr.com', '$70p.h.', 'paulmillr', '1232668/paul-miller', 'paulmillr.com', gravatarUrl+'d342e4ef045c54a6a6f41d070d8a0406?s=420', null, [@brunch]
  @raynos = aDev 'Jake Verbaten', 'raynos2@gmail.com', '-', 'raynos', '419970/raynos', 'resume.github.com/?Raynos', gravatarUrl+'d840cb1fb7e828284011cc08f40a1015?s=420', null, [@node,@javascript,@jquery,@express,@backbone,@coffee]
  @linus = aDev 'Linus G Thiel', 'linus@hanssonlarsson.se', '-', 'linus', '295262/linus-g-thiel', 'github.com/raynos', gravatarUrl+'01e61a98122184b3c14959bcac5dba76?s=420', null, [@node,@javascript,@coffee,@express,@redis,@jquery,@socketio]

  @khanmurtuza = aDev 'Murtuza Khan', 'khanmurtuza@gmail.com', '-', 'khanmurtuza', '470682/mkso', 'github.com/khanmurtuza', gravatarUrl+'4c5d88314e94d0edae14e0adcf0cf135?s=420', null, [@android,@java,@spring,@python,@html5]
  @jstart = aDev 'Christopher Truman', 'cleetruman@gmail.com', '-', 'jstart', '150920/chris-truman', 'dontmakecrap.tumblr.com', gravatarUrl+  'c3b9a15ccd23da3d3479ee92bf6a8578?s=420', null, [@android,@ruby,@iphone,@objectivec,@xcode]   # 2:13 (w-out skills)
  @ashokvarma2 = aDev 'Ashok Varma', 'ashokvarma2@gmail.com', '-', null, null, 'appstark.com', noAvatarUrl, null, [@ror,@android,@javascript,@css,@html,@backbone,@objectivec]  # 1:55 (w skills)
  @justinlloyd = aDev 'Justin Lloyd ', 'justin@justinlloyd.org', '-', null, null, 'justinlloyd.org', noAvatarUrl, 'linkedin.com/in/justinlloyd', [@csharp,@ruby,@android,@dotnet,@mssql,@mysql,@java,@php,@windows,@cpp] # 2:29 (w-out skills)
  @sweetleon = aDev 'Lenny Turetsky', 'airpair@firstgearconsulting.com', '-', 'sweetleon', '318233/lenny-t', 'linkedin.com/in/LennyTuretsky', noAvatarUrl, null, [@backbone,@javascript,@ror,@android,@linux,@unix] # 1:59 (w-out skills)
  # @ghub = aDev 'name', 'email', '-', 'ghub', 'so', 'homeurl', 'avatarurl', [@skill,@skill,@skill]
]