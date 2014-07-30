Speakers = require '../data/airconfspeakers'

convert = (username, slugUrl, social) =>
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

module.exports =

  workshops:

    'danielroseman':  convert 'danielroseman', 'new-in-django-1.7', so:'104349/daniel-roseman'
    'ryanbigg':       convert 'ryanbigg', 'refactoring-large-rails-code', so:'15245/ryan-bigg'
    'abedra':         convert 'abedra', 'repsheet-dynamic-security-controls', tw: 'abedra'
    'jefflinwood':    convert 'jefflinwood', 'twilio-voice-sms-integration', in: 'sy5n2q8o2i49/MI4rhSkAQM'
    'philsturgeon':   convert 'philsturgeon', 'php-town-crier', tw: 'philsturgeon'
    'annisgrey':      convert 'annisgrey', 'transitioning-to-consulting-for-developers', tw:'annisgrey'
    'joshowens':      convert 'joshowens', 'learn-meteorjs-1.0', tw:'joshowens'
    'arunoda':        convert 'arunoda', 'client-side-javascript-error-tracking', tw: 'arunoda'
    'adymo':          convert 'adymo', 'rails-performance-optimization-q-and-a', in: 'sy5n2q8o2i49/1KB9BDtDYm'
    'felienne':       convert 'felienne', 'spreadsheets-graph-databases', tw: 'felienne'
    'brianmhunt':     convert 'brianmhunt', 'spreadsheets-graph-databases', so: '19212/brian-m-hunt'
    'andrewchen':     convert 'andrewchen', 'zero-to-product-market-fit', tw:'andrewchen'
    'hcatlin':        convert 'hcatlin', 'css-vs-sass', tw:'hcatlin'
    'evgenyz':        convert 'evgenyz', 'test-driven-infrastructure', in: 'sy5n2q8o2i49/9ZPSg_JcCY'
    'basarat':        convert 'basarat', 'javascript-prototypal-inheritance', so: '390330/basarat'
    'larskotthoff':   convert 'larskotthoff', 'quickstart-to-d3js', so: '1172002/lars-kotthoff'
    'urish':          convert 'urish', 'angularjs-performance-pitfalls', in: 'sy5n2q8o2i49/H_-Va_zs6e'
    'antonioribeiro': convert 'antonioribeiro', 'laravel-apps-and-composer-packages', so: '1959747/antonio-carlos-ribeiro'
    'al_the_x':       convert 'al_the_x', 'pair-programming-coding-dojo', in: 'sy5n2q8o2i49/yTIUuanj7P'
    'jayfields':      convert 'jayfields', 'effectiv-unit-tests', tw: 'thejayfields'
    'arafalov':       convert 'arafalov', 'discovering-your-inned-search-engine', tw: 'arafalov'
    'kn0tch':         convert 'kn0tch', 'containerizing-production-app', tw: 'kn0tch'
    'fluffyjack':     convert 'fluffyjack', 'is-swift-that-swift', in: 'sy5n2q8o2i49/oNxzjUMtdW'
    'agravier':       convert 'agravier', 'data-processing-with-python', in: 'sy5n2q8o2i49/UFhmGZ-ZyR'
    'bantik':         convert 'bantik', 'open-source-and-women', tw: 'bantik'

    'mariovisic':     d: 'Sat, 23rd Aug 23:00 GMT', n: 'Mario Visic', c: "Conference Speaker", t: "ActiveRecord without active record", u: 'mariovisic', tw: 'mariovisic', tags: ['rails','activerecord'], g: 'db58858a009745e96871e04ef497269a', a: "An exercise in using the popular and well maintained ActiveRecord library in a web application while avoiding the active record pattern."
    'domenic':        d: 'Tue, 12th Aug 00:00 GMT', n: 'Domenic Denicola', c: "Google Chrome Team", t: "Building web apps from reusable pieces w npm", gh: 'domenic', tags: ['nodejs','npm'], u: 'domenic', g: 'c6d819207a3010b39d13e1f59f2c0029', a: "Description coming soon"
    'matsko':         d: 'Wed, 13th Aug 04:00 GMT', n: 'Matias Niemelä', c: "Angular Core Team", t: "Awesome Interfaces with AngularJS Animations", gh: 'matsko', tags: ['anguarljs','ng-animate'], u: 'matsko', g: '3c0ca2c60c5cc418c6b3dbed47b23b69', a: "Description coming soon"
    'ehrenreilly':    d: 'Thu, 14th Aug 01:00 GMT', n: 'Ehren Reilly', c: "Growth at Glassdoor", t: "Understanding Google's <br />Panda Algorithm", in: '/sy5n2q8o2i49/HEeMIzWKij', tags: ['seo'], u: 'ehrenreilly', g: '31e630fa1f4c36ebb986812309f09acb', a: "Google's Panda algorithm was designed to rewards sites that consistently deliver high quality experiences to users. But in SEO circles, Panda is often caricatured as a great and mysterious taker away of traffic. The truth is, search rankings are a zero sum game. Learn how to get Panda algorithm to work in your favor."
    'acuppy1':        d: '!Thu, 14th Aug 17:00 GMT', n: 'Adam Cuppy', c: "Conference Speaker", t: "Taming Chaotic Specs: <br />RSpec Design Patterns", in: 'sy5n2q8o2i49/OfJ8u7KW5E', tags: ['rails','rspec'], u: 'acuppy', g: '35e0dbc9533ce3d90527eeec998d9725', a: "Hate when testing takes 3x as long because your specs are hard to understand? Following a few simple patterns, you can easily take a bloated spec and make it readable, DRY and simple to extend. This workshop is a refactor kata taking a bloated sample spec and making it manageable, readable and concise."
    'zopatista':      d: '!Fri, 15th Aug 01:00 GMT', n: 'Martijn Pieters', c: "All-time #1 Python Answerer", t: "What's New in <br />Python 3.4", so: '100297/martijn-pieters', tags: ['python'], u: 'zopatista', g: '09c1bb74564cba5aa5e1005e869499d4', a: "Description coming soon"
    'hackerpreneur':  d: '!Sat, 16th Aug 16:00 GMT', n: 'Jonathon Kresner', c: "AirPair Founder", t: "Validated <br />Building", tw: 'hackerpreneur', tags: ['lean-startup'], u: 'hackerpreneur', g: '780d02a99798886da48711d8104801a4', a: "Every piece in AirPair was built MVPed using a sticky taped solution of existing software products before being custom coded. Learn how AirPair generated 15 paying customers before we'd written a single line of code."
    'searls':         d: '!Sun, 17th Aug 22:00 GMT', n: 'Justin Searls', c: "Cartoon Guy", t: "The 'Rails of JavaScript' won't be a Framework", tw: 'searls', tags: ['rails'], u: 'searls', g: 'e6c6e133e74c3b83f04d2861deaa1c20', a: "The failure of Rails has been its perception as 'best web framework ever' instead of 'best web framework for apps like Basecamp'. Given that, it's clear why Rails makes writing a UI in HTML a joy but does few favors for JavaScript-heavy apps. We'll show how with Lineman.js & tools extracted find JavaScript joy!"
    'toddmotto':      d: '!Sat, 9th Aug 12:00 GMT', n: 'Todd Motto', c: "HTML5 Google Developer Expert", t: "Learning AngularJS <br />in 1 Day", tw: 'toddmotto', tags: ['angularjs'], u: 'toddmotto', g: 'b56bb22b3a4b83c6b534b4c114671380', a: "Angular is a client-side MVC/MVVM framework built in JavaScript, essential for modern single page web applications (and even websites). This session is a full end to end crash course from my experiences, advice and best practices I've picked up from using it."
    'acuppy2':        d: '!Wed, 20th Aug 17:00 GMT', n: 'Adam Cuppy', c: "Conference Speaker", t: "Taming Chaotic Specs: <br />RSpec Design Patterns", in: 'sy5n2q8o2i49/OfJ8u7KW5E', tags: ['rails','rspec'], u: 'acuppy', g: '02bea4b58d39ba964c32c1609c728c53', a: "Hate when testing takes 3x as long because your specs are hard to understand? Following a few simple patterns, you can easily take a bloated spec and make it readable, DRY and simple to extend. This workshop is a refactor kata taking a bloated sample spec and making it manageable, readable and concise."
    'andrew_weiss':   d: '!Thu, 21st Aug 17:00 GMT', n: 'Andrew Weiss', c: "Consultant at Mircrosoft", t: "Cross-Platform Configuration w PowerShell", in: 'sy5n2q8o2i49/KhUQbZLqfq', tags: ['powershell'], u: 'andrew_weiss', g: '487151c85bfb33f3249c5668874719d2', a: "Join me for a crash course in PowerShell and its configuration management capabilities. In this session, you’ll learn how PowerShell can be used to create consistent, Windows and Linux based development environments. We’ll also explore some of the fundamentals of the popular application distribution system known as Docker and how we can use PowerShell to provision and manage our Docker hosts."
    'amirrajan':      d: 'Fri, 22nd Aug 15:00 GMT', n: 'Amir Rajan', c: "Apple Design Award Winner", l: "Beginner", t: "How to Con Your Way to <br />App Store #1", tw: 'ADarkRoomiOS', tags: ['app-store'], u: 'amirrajan', g: '433d6daba7a9f7e563b793c0890ef906', a: "What does it take to climb your way to the top spot in the App Store? What kind of revenue can you expect from building for-pay iOS apps? How does news coverage and social media affect download rates? Amir Rajan, creator of the A Dark Room iOS, will share the wisdom he's gained from climbing to the #1 spot. He'll share revenue and provide insight into the ranking system. He'll talk about pricing strategies, combating clones, dealing with negative reviews, and what control you have (and don't have) if your app goes viral.", b: "Amir Rajan is a jack of all trades. He has expertise in a number languages (C#, F#, Ruby, Scala, JavaScript, and Objective C). He is also the creator of A Dark Room iOS. This minimalist text based RPG conquered the world and took the #1 spot in the App Store across 5 countries. This chart topping iOS game and its unprecedented rise to the top has received critical acclaim from Paste Magazine, Giant Bomb, Forbes, The Huffington Post, Cult of Mac, and The New Yorker."
    '2upmedia':       d: 'Tue, 26th Aug 18:00 GMT', n: 'Jorge Colon', c: "PHP Wiz kiz", t: "Emulate staging servers w <br />Vagrant, CentOS & LAMP", in: 'sy5n2q8o2i49/cPXFL7mBie', tags: ['vagrant','centos','lamp'], u: '2upmedia', g: 'b93914137ae67057880798210dc80e20', a: "Some developers still use FTP and a live server, some have graduated to running a development environment locally, but the savvy emulate the live server locally with a virtual server. Vagrant makes this so easy. We'll go through how to install Vagrant, configuring a basic Vagrant configuration, then install LAMP on CentOS."
    'auser':          d: '!Thu, 28th Aug 16:00 GMT', n: 'Ari Lerner', c: "ng-newsletter Creator", t: "Powering interfaces <br />with AngularJS", u: 'auser', gh: 'auser', tags: ['angularjs'], g: '0ec7fe2c17900b71bd85ff63fc9d8a17', a: "Ari is a co-author of The Rails 4 Way, Riding Rails with AngularJS and the Beginner’s Guide to AngularJS. Recently Ari has been training folks in AngularJS at Hack Reactor as a JavaScript teacher. Ari also publishes ng-newsletter.com."
    'abeisgreat':     d: '!Sat, 30th Aug 16:00 GMT', n: 'Abe Haskins', c: "Angularfire Contributor", t: "Fast Client-Side Apps w AngularFire", gh: 'abeisgreat', tags: ['firebase','angularjs'], u: 'abeisgreat', g: 'fbb79df0f24e736c8e37f9f195a738cc', a: "Description coming soon"
    'ronlichty':      d: '!Sat, 30th Aug 22:00 GMT', n: 'Ron Lichty', c: "Agile Book Author", t: "Crash Course: Managing Software People and Teams", tw: 'ronlichty', tags: ['agile','extreme-programming'], u: 'ronlichty', g: '4974bd42e635147b1fee8323f122acc9', a: "Description coming soon"
    'mikegrassotti':  d: '!Sun, 31st Aug 16:00 GMT', n: 'Michael Grassotti', c: "All-time Ember.js #1 Answerer", t: "Something<br />Ember.js", so: '983357/mike-grassotti', tags: ['ember.js'], u: 'mikegrassotti', g: '9b9536f792ccd2b3641d8e3f9a157167', a: "Description coming soon"
    'u':              d: '', n: '', c: "", t: "", in: '', tags: [''], u: '', g: '', a: ""
    'count':          70

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
