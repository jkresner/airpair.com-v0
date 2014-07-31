Speakers = require '../data/airconfspeakers'

convert = (username, slugUrl, social) =>
  moment = require('moment-timezone')
  {name, shortBio, fullBio, talkTitle, talkDescription, talkTags, level, gravatar, pdt} = _.find Speakers, (s) -> s.username == username
  result = _.extend {u:username,slug: slugUrl}, social
  result = _.extend result,
    utc: pdt
    n: name
    b: fullBio
    c: shortBio
    t: talkTitle
    a: talkDescription
    l: level
    g: gravatar
    tags: talkTags.split(' ')
    calutc: moment(pdt).tz('Etc/GMT+3').format('YYYYMMDDTHHmmss') + "Z"
    calend: moment(pdt).tz('Etc/GMT+2').format('YYYYMMDDTHHmmss') + "Z"

module.exports =

  workshops:

    #wk 1
    'danielroseman':  convert 'danielroseman', 'new-in-django-1.7', so:'104349/daniel-roseman'
    'ryanbigg':       convert 'ryanbigg', 'refactoring-large-rails-code', so:'15245/ryan-bigg'
    'abedra':         convert 'abedra', 'repsheet-dynamic-security-controls', tw: 'abedra'
    'uxceo':          convert 'uxceo', 'effective-experiments-for-product-development', tw: 'uxceo'    
    'jefflinwood':    convert 'jefflinwood', 'twilio-voice-sms-integration', in: 'sy5n2q8o2i49/MI4rhSkAQM'
    'cherylquirion':  convert 'cherylquirion', 'lean-visual-strategy', tw: 'cherylquirion'
    'philsturgeon':   convert 'philsturgeon', 'php-town-crier', tw: 'philsturgeon'
    'mhartl':         convert 'mhartl', 'publishing-at-the-speed-of-ruby', tw: 'mhartl'
    'annisgrey':      convert 'annisgrey', 'transitioning-to-consulting-for-developers', tw:'annisgrey'
    'jenius':         convert 'jenius', 'learn-git-and-github', gh:'jenius'

    #wk 2
    'arunoda':        convert 'arunoda', 'client-side-javascript-error-tracking', tw: 'arunoda'
    'peterarmstrong': convert 'peterarmstrong', 'why-publish-developer-books', tw: 'peterarmstrong'
    'searls':         convert 'searls', 'simplifying-rails-tests', tw: 'searls'
    'domenic':        d: 'Tue, 12th Aug 00:00 GMT', utc: '2014-08-12T00:00:00.000Z', n: 'Domenic Denicola', c: "Google Chrome Team", t: "Building web apps from reusable pieces w NPM", gh: 'domenic', tags: ['nodejs','npm'], u: 'domenic', g: 'c6d819207a3010b39d13e1f59f2c0029', a: "Description coming soon"
    'adymo':          convert 'adymo', 'rails-performance-optimization-q-and-a', in: 'sy5n2q8o2i49/1KB9BDtDYm'
    'matsko':         convert 'matsko', 'animations-with-angularjs', gh: 'matsko'
    'felienne':       convert 'felienne', 'spreadsheets-graph-databases', tw: 'felienne'
    'ehrenreilly':    convert 'ehrenreilly', 'panda-user-experience-and-seo', in: '/sy5n2q8o2i49/HEeMIzWKij'
    'brianmhunt':     convert 'brianmhunt', 'spreadsheets-graph-databases', so: '19212/brian-m-hunt'
    'johnscattergood':convert 'johnscattergood', 'automating-marine-container-terminals', tw: 'johnscattergood'
    'zopatista':      convert 'zopatista', 'python-3.4', so: '100297/martijn-pieters'
    'agravier':       convert 'agravier', 'data-processing-with-python', in: 'sy5n2q8o2i49/UFhmGZ-ZyR'
    'andrewchen':     convert 'andrewchen', 'zero-to-product-market-fit', tw:'andrewchen'
    'hackerpreneur':  d: '!Sat, 16th Aug 16:00 GMT', n: 'Jonathon Kresner', c: "AirPair Founder", t: "Validated <br />Building", tw: 'hackerpreneur', tags: ['lean-startup'], u: 'hackerpreneur', g: '780d02a99798886da48711d8104801a4', a: "Every piece in AirPair was built MVPed using a sticky taped solution of existing software products before being custom coded. Learn how AirPair generated 15 paying customers before we'd written a single line of code."

    #wk 3
    'hcatlin':        convert 'hcatlin', 'css-vs-sass', tw:'hcatlin'
    'joshowens':      convert 'joshowens', 'learn-meteorjs-1.0', tw:'joshowens'
    'evgenyz':        convert 'evgenyz', 'test-driven-infrastructure', in: 'sy5n2q8o2i49/9ZPSg_JcCY'
    'acuppy':         convert 'acuppy', 'taming-chaotic-specs-rspec', in: 'sy5n2q8o2i49/OfJ8u7KW5E'
    'dzello':         convert 'dzello', 'store-json-in-cassandra', tw: 'dzello'
    'kfaustino':      convert 'kfaustino', 'introduction-to-rails-4', tw: 'kfaustino'
    'amirrajan':      convert 'amirrajan', 'make-it-to-number-1-in-the-app-store', tw: 'ADarkRoomiOS'
    'basarat':        convert 'basarat', 'javascript-prototypal-inheritance', so: '390330/basarat'
    'larskotthoff':   convert 'larskotthoff', 'quickstart-to-d3js', so: '1172002/lars-kotthoff'
    'mariovisic':     convert 'mariovisic', "activerecord-without-active-record", tw: 'mariovisic'    

    'urish':          convert 'urish', 'angularjs-performance-pitfalls', in: 'sy5n2q8o2i49/H_-Va_zs6e'
    'antonioribeiro': convert 'antonioribeiro', 'laravel-apps-and-composer-packages', so: '1959747/antonio-carlos-ribeiro'
    'al_the_x':       convert 'al_the_x', 'pair-programming-coding-dojo', in: 'sy5n2q8o2i49/yTIUuanj7P'
    'arafalov':       convert 'arafalov', 'discovering-your-inned-search-engine', tw: 'arafalov'
    'kn0tch':         convert 'kn0tch', 'containerizing-production-app', tw: 'kn0tch'
    'fluffyjack':     convert 'fluffyjack', 'is-swift-that-swift', in: 'sy5n2q8o2i49/oNxzjUMtdW'
    'bantik':         convert 'bantik', 'open-source-and-women', tw: 'bantik'
    'jayfields':      convert 'jayfields', 'effectiv-unit-tests', tw: 'thejayfields'
    'acuppy2':        _.extend (convert 'acuppy', 'taming-chaotic-specs-rspec', in: 'sy5n2q8o2i49/OfJ8u7KW5E'), { utc: "2014-08-27T17:00:00.000Z",  }
    
    'toddmotto':      d: '!Sat, 9th Aug 12:00 GMT', n: 'Todd Motto', c: "HTML5 Google Developer Expert", t: "Learning AngularJS <br />in 1 Day", tw: 'toddmotto', tags: ['angularjs'], u: 'toddmotto', g: 'b56bb22b3a4b83c6b534b4c114671380', a: "Angular is a client-side MVC/MVVM framework built in JavaScript, essential for modern single page web applications (and even websites). This session is a full end to end crash course from my experiences, advice and best practices I've picked up from using it."   
    'andrew_weiss':   d: '!Thu, 21st Aug 17:00 GMT', n: 'Andrew Weiss', c: "Consultant at Mircrosoft", t: "Cross-Platform Configuration w PowerShell", in: 'sy5n2q8o2i49/KhUQbZLqfq', tags: ['powershell'], u: 'andrew_weiss', g: '487151c85bfb33f3249c5668874719d2', a: "Join me for a crash course in PowerShell and its configuration management capabilities. In this session, you’ll learn how PowerShell can be used to create consistent, Windows and Linux based development environments. We’ll also explore some of the fundamentals of the popular application distribution system known as Docker and how we can use PowerShell to provision and manage our Docker hosts."
    '2upmedia':       d: 'Tue, 26th Aug 18:00 GMT', n: 'Jorge Colon', c: "PHP Wiz kiz", t: "Emulate staging servers w <br />Vagrant, CentOS & LAMP", in: 'sy5n2q8o2i49/cPXFL7mBie', tags: ['vagrant','centos','lamp'], u: '2upmedia', g: 'b93914137ae67057880798210dc80e20', a: "Some developers still use FTP and a live server, some have graduated to running a development environment locally, but the savvy emulate the live server locally with a virtual server. Vagrant makes this so easy. We'll go through how to install Vagrant, configuring a basic Vagrant configuration, then install LAMP on CentOS."
    'auser':          d: '!Thu, 28th Aug 16:00 GMT', n: 'Ari Lerner', c: "ng-newsletter Creator", t: "Powering interfaces <br />with AngularJS", u: 'auser', gh: 'auser', tags: ['angularjs'], g: '0ec7fe2c17900b71bd85ff63fc9d8a17', a: "Ari is a co-author of The Rails 4 Way, Riding Rails with AngularJS and the Beginner’s Guide to AngularJS. Recently Ari has been training folks in AngularJS at Hack Reactor as a JavaScript teacher. Ari also publishes ng-newsletter.com."
    'abeisgreat':     d: '!Sat, 30th Aug 16:00 GMT', n: 'Abe Haskins', c: "Angularfire Contributor", t: "Fast Client-Side Apps w AngularFire", gh: 'abeisgreat', tags: ['firebase','angularjs'], u: 'abeisgreat', g: 'fbb79df0f24e736c8e37f9f195a738cc', a: "Description coming soon"
    'ronlichty':      d: '!Sat, 30th Aug 22:00 GMT', n: 'Ron Lichty', c: "Agile Book Author", t: "Crash Course: Managing Software People and Teams", tw: 'ronlichty', tags: ['agile','extreme-programming'], u: 'ronlichty', g: '4974bd42e635147b1fee8323f122acc9', a: "Description coming soon"
    'mikegrassotti':  d: '!Sun, 31st Aug 16:00 GMT', n: 'Michael Grassotti', c: "All-time Ember.js #1 Answerer", t: "Something<br />Ember.js", so: '983357/mike-grassotti', tags: ['ember.js'], u: 'mikegrassotti', g: '9b9536f792ccd2b3641d8e3f9a157167', a: "Description coming soon"
    'u':              d: '', n: '', c: "", t: "", in: '', tags: [''], u: '', g: '', a: ""
    'count':          80

    # 'stefanpenner':   d: '!Sun, 10th Aug 22:00 GMT', n: 'Stefan Penner', c: "Ember.js Core Team", t: "Testing the <br />Ember-CLI", gh: 'stefanpenner', tags: ['ember.js'], u: 'stefanpenner', g: '8ccebbc3d28f903d5c214efd3447ac71', a: "Description coming soon"
    # 'wycats':         d: '!Tue, 5th Aug 16:00 GMT', n: 'Yehuda Katz', c: "Rails Co-creator", t: "How to Build a Smart Profiler for Rails", gh: 'wycats', tags: ['rails'], u: 'wycats', g: '428167a3ec72235ba971162924492609', a: "Customers love fast apps. We've got tools to help us figure out how our Rails apps are performing on our development machines, but that's not what matters. It's critical that we also be able to measure how our apps are actually performing in the production environment."


  so15:
    'jquery':     name: 'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
    'ruby-on-rails':name: 'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
    'python':     name: 'Martijn Pieters', me: 'zopatista', claim: 'All-time Python #1 Answerer'
    'laravel':    name: 'Antonio Carlos Ribeiro', me: 'antonioribeiro', claim: 'All-time Laravel #1 Answerer'
    'typescript': name: 'Basarat Ali', me: 'basarat', claim: 'Typescript Top Answerer'
    'uikit':      name: 'Nevan King', me: 'nevanking', claim: 'UIkit Top Answerer'
    'uilabel':    name: 'Nevan King', me: 'nevanking', claim: 'UIlabel Top Answerer'
    'cocoa-touch':name: 'Nevan King', me: 'nevanking', claim: 'Cocoa-touch Top Answerer'
    'scheme':     name: 'Chris K. Jester-Young', me: 'cky', claim: 'Scheme Top Answerer'
    'd3.js':      name: 'Lars Kotthoff', me: 'larskotthoff', claim: 'd3.js Top Answerer'
    'google-chrome':name: 'Todd Motto', me: 'toddmotto', claim: 'Google Chrome GDE'
    'ruby':       name: 'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
    'android' :   name: 'Ran Nachmany', me: 'rannachmany', claim: 'Android Google Developer Expert'
    'angularjs':  name: 'Matias Niemelä', me: 'matsko', claim: 'AngularJS Core Team'
    'php':        name: 'Phil Sturgeon', me: 'philsturgeon', claim: 'PHP Top Answerer'
    'codeigniter':name: 'Phil Sturgeon', me: 'philsturgeon', claim: 'All-time CodeIgniter #1 Answerer'
    'node.js':    name: 'Tim Caswell', me: 'creationix', claim: 'Early Node.js Contributor'
    'nginx':      name: 'Aaron Bedra', me: 'abedra', claim: 'Early Node.js Contributor'
    'ios':        name: 'Wain Glaister', me: 'wain', claim: 'iOS Top Answerer'
    'django':     name: 'Daniel Roseman', me: 'danielroseman', claim: 'Django #1 Answerer'
    'ember.js':   name: 'Michael Grassotti', me: 'mikegrassotti', claim: 'All-time Ember.js #1 Answerer'
    'express':    name: 'Peter Lyson', me: 'focusaurus', claim: 'All-time Express #1 Answerer'
    'mysql':      name: 'Alex Bolenok', me: 'quassnoi', claim: 'All-time MySql Top Answerer'
    'twilio':     name: 'Jeff Linwood', me: 'jefflinwood', claim: 'Twilio book author'
    # 'asp.net':    name: 'Amir Rajan', me: 'amirrajan', claim: 'ASP .net AirPair Expert'
    # 'c++':        name: 'Steve Purves', me: 'stevejpurves', claim: 'C++ AirPair Expert'
    # 'java':       name: 'Marko Topolnik', me: 'marko', claim: 'Java Top Answerer'
    # 'c#':         name: 'John Feminella', me: 'john-feminella', claim: 'C# Top Answerer'


  so10:
    'ruby':       name: 'Yehuda Katz', me: 'wycats', claim: 'Rails Core Team Member'
    'python':     name: 'Daniel Roseman', me: 'danielroseman', claim: 'Django #1 Answerer'
    'android' :   name: 'Ran Nachmany', me: 'rannachmany', claim: 'Android Google Developer Expert'
    'angularjs':  name: 'Matias Niemelä', me: 'matsko', claim: 'AngularJS Core Team'
    'php':        name: 'Phil Sturgeon', me: 'philsturgeon', claim: 'PHP Top Answerer'
    'node.js':    name: 'Tim Caswell', me: 'creationix', claim: 'Early Node.js Contributor'
    'ios':        name: 'Wain Glaister', me: 'wain', claim: 'iOS Top Answerer'
    'asp.net':    name: 'Amir Rajan', me: 'amirrajan', claim: 'ASP .net AirPair Expert'
    'c++':        name: 'Steve Purves', me: 'stevejpurves', claim: 'C++ AirPair Expert'
    'c#':         name: 'John Feminella', me: 'john-feminella', claim: 'C# Top Answerer'
    'java':       name: 'Marko Topolnik', me: 'marko', claim: 'Java Top Answerer'
