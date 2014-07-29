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
    'ryanbigg':       d: 'Mon, 4th Aug 22:00 GMT', n: 'Ryan Bigg', c: "Rails Book Author", t: "Refactoring Big Features <br />in Large Codebases", so: '15245/ryan-bigg', tags: ['rails','spree'], u: 'ryanbigg', g: '9a2a53db8e9b4476038c94a64b32833f', a: "Spree had a problem: the adjustments system was slow and difficult to understand. Over a period of some months, we refactored the code to be much faster and cleaner. The talk will cover the unique challenges that faced Spree and how we overcome them."
    'abedra':         d: 'Tue, 5th Aug 16:00 GMT', n: 'Aaron Bedra', c: "Groupon Intrastructure", t: "Creating Dynamic Security Controls With Repsheet", slug: "repsheet-dynamic-security-controls", tw: 'abedra', tags: ['repsheet','rails','mod-security'], u: 'abedra', g: '24659470071279a42020d5b87411598e', a: "It's 2014 and our security controls should start acting like it. We maintain static controls on security because we lack the intelligence to adapt them to the situation at hand. Join Aaron as he walks you through creating dynamic security controls using the Repsheet threat intelligence and reputation framework."
    'jefflinwood':    d: 'Wed, 6th Aug 17:00 GMT', n: 'Jeff Linwood', c: "Twilio Book Author", t: "Voice & SMS <br />for Your Apps", slug: 'twilio-voice-sms-integr', in: 'sy5n2q8o2i49/MI4rhSkAQM', tags: ['twilio'], u: 'jefflinwood', g: '088bce2168389e26b6d4a8592a950299', a: "We'll cover the basics of using Twilio for interactive voice and SMS from web applications. This is a session for web developers who haven't used Twilio before, but are curious to see what it can do for their projects. "
    'andrewchen':     d: '!Thu, 7th Aug 22:00 GMT', n: 'Andrew Chen', c: "Entrepreneur, ex-Venture Capital", t: "Zero to <br />Product Market Fit", slug: "andrew-chen-product-market-fit", tw: 'andrewchen', tags: ['internet','growth'], u: 'andrewchen', g: '2c9c63e72bc96de12e6acd7ba07d6f02', a: "Are you an Engineer with dreams of traction? In this rare opportunity, spend an hour in Q & A with Andrew Chen about how to find Product Market fit for your idea."
    'toddmotto':      d: '!Sat, 9th Aug 12:00 GMT', n: 'Todd Motto', c: "HTML5 Google Developer Expert", t: "Learning AngularJS <br />in 1 Day", tw: 'toddmotto', tags: ['angularjs'], u: 'toddmotto', g: 'b56bb22b3a4b83c6b534b4c114671380', a: "Angular is a client-side MVC/MVVM framework built in JavaScript, essential for modern single page web applications (and even websites). This session is a full end to end crash course from my experiences, advice and best practices I've picked up from using it."
    'arunoda':        d: 'Mon, 11th Aug 16:00 GMT', n: 'Arunoda Susiripala', c: "MeteorHacks Author", t: "Client Side <br />Error Tracking", gh: 'arunoda', tags: ['javascript'], u: 'arunoda', g: 'ab13df38843556b57f7d2f6fe78003cf', a: "Debugging client side errors is easy in development thanks to browser dev tools. But doing them in production is a nightmare, since you don't have access to users' browser. Tracking errors with `window.onerror` is the easiest, but the least useful way. Let's try to learn more about errors and track them."
    'domenic':        d: 'Tue, 12th Aug 00:00 GMT', n: 'Domenic Denicola', c: "Google Chrome Team", t: "Building web apps from reusable pieces w npm", gh: 'domenic', tags: ['nodejs','npm'], u: 'domenic', g: 'c6d819207a3010b39d13e1f59f2c0029', a: "Description coming soon"
    'adymo':          d: 'Tue, 12th Aug 23:00 GMT', n: 'Alexander Dymo', c: "YCombinator Alum", t: "Rails Performance<br />Q & A", in: 'sy5n2q8o2i49/1KB9BDtDYm', tags: ['rails'], u: 'adymo', g: '990f1e2f3c6871d4305d3a316902b1bf', a: "Alexander is an entrepreneur, Y Combinator alum and Rails Performance Junky. He has 9 years of experience of Rails application development and performance optimization. In 2014 Alex has talked at conference and published various articles on the subject of Rails performance and is open for a 2 hour Q&A."
    'matsko':         d: 'Wed, 13th Aug 04:00 GMT', n: 'Matias Niemelä', c: "Angular Core Team", t: "Awesome Interfaces with AngularJS Animations", gh: 'matsko', tags: ['anguarljs','ng-animate'], u: 'matsko', g: '3c0ca2c60c5cc418c6b3dbed47b23b69', a: "Description coming soon"
    'felienne':       d: 'Wed, 13th Aug 07:00 GMT', n: 'Felienne Hermans', c: "PhD & Spreadsheets Professor", t: "Graph Databases and Spreadsheets", tw: 'felienne', tags: ['neo4j','excel'], u: 'felienne', g: 'f524745bb9975ba777b5c4a9922eb614', a: "Spreadsheets are graphs too! Using Neo4J as backend to store spreadsheet information, this presentation explains how I use Neo4J as a database for a tool that calculate spreadsheet metrics."
    'ehrenreilly':    d: 'Thu, 14th Aug 01:00 GMT', n: 'Ehren Reilly', c: "Growth at Glassdoor", t: "Understanding Google's <br />Panda Algorithm", in: '/sy5n2q8o2i49/HEeMIzWKij', tags: ['seo'], u: 'ehrenreilly', g: '31e630fa1f4c36ebb986812309f09acb', a: "Google's Panda algorithm was designed to rewards sites that consistently deliver high quality experiences to users. But in SEO circles, Panda is often caricatured as a great and mysterious taker away of traffic. The truth is, search rankings are a zero sum game. Learn how to get Panda algorithm to work in your favor."
    'acuppy1':        d: '!Thu, 14th Aug 17:00 GMT', n: 'Adam Cuppy', c: "Conference Speaker", t: "Taming Chaotic Specs: <br />RSpec Design Patterns", in: 'sy5n2q8o2i49/OfJ8u7KW5E', tags: ['rails','rspec'], u: 'acuppy', g: '35e0dbc9533ce3d90527eeec998d9725', a: "Hate when testing takes 3x as long because your specs are hard to understand? Following a few simple patterns, you can easily take a bloated spec and make it readable, DRY and simple to extend. This workshop is a refactor kata taking a bloated sample spec and making it manageable, readable and concise."
    'zopatista':      d: '!Fri, 15th Aug 01:00 GMT', n: 'Martijn Pieters', c: "All-time #1 Python Answerer", t: "What's New in <br />Python 3.4", so: '100297/martijn-pieters', tags: ['python'], u: 'zopatista', g: '09c1bb74564cba5aa5e1005e869499d4', a: "Description coming soon"
    'hackerpreneur':  d: '!Sat, 16th Aug 16:00 GMT', n: 'Jonathon Kresner', c: "AirPair Founder", t: "Validated <br />Building", tw: 'hackerpreneur', tags: ['lean-startup'], u: 'hackerpreneur', g: '780d02a99798886da48711d8104801a4', a: "Every piece in AirPair was built MVPed using a sticky taped solution of existing software products before being custom coded. Learn how AirPair generated 15 paying customers before we'd written a single line of code."
    'searls':         d: '!Sun, 17th Aug 22:00 GMT', n: 'Justin Searls', c: "Cartoon Guy", t: "The 'Rails of JavaScript' won't be a Framework", tw: 'searls', tags: ['rails'], u: 'searls', g: 'e6c6e133e74c3b83f04d2861deaa1c20', a: "The failure of Rails has been its perception as 'best web framework ever' instead of 'best web framework for apps like Basecamp'. Given that, it's clear why Rails makes writing a UI in HTML a joy but does few favors for JavaScript-heavy apps. We'll show how with Lineman.js & tools extracted find JavaScript joy!"
    'hcatlin':        convert 'hcatlin', 'css-vs-sass', tw:'hcatlin'
    'joshowens':      convert 'joshowens', 'learn-meteorjs-1.0', tw:'joshowens'
    'philsturgeon':   d: '!Mon, 18th Aug 22:00 GMT', n: 'Phil Sturgeon', c: "All-time CodeIgniter #1 Answerer", t: "API <br />Pain Points", gh: 'philsturgeon', tags: ['php','api'], u: 'philsturgeon', g: '14df293d6c5cd6f05996dfc606a6a951', a: "Description coming soon"
    'evgenyz':        d: 'Tue, 19th Aug 17:00 GMT', n: 'Evgeny Zislis', c: "devops.co.il Founder", t: "Infrastructure as Code <br />Test Driven Chef", in: 'sy5n2q8o2i49/9ZPSg_JcCY', tags: ['chef'], u: 'evgenyz', g: '35d78874c6ba5c64db3256f6868515dc', a: "Every second company now uses Puppet or Chef. But very few apply similar testing discipline to infrastructure as application code. In just over an hour you will learn the various ways of writing tests when using Chef."
    'acuppy2':        d: '!Wed, 20th Aug 17:00 GMT', n: 'Adam Cuppy', c: "Conference Speaker", t: "Taming Chaotic Specs: <br />RSpec Design Patterns", in: 'sy5n2q8o2i49/OfJ8u7KW5E', tags: ['rails','rspec'], u: 'acuppy', g: '02bea4b58d39ba964c32c1609c728c53', a: "Hate when testing takes 3x as long because your specs are hard to understand? Following a few simple patterns, you can easily take a bloated spec and make it readable, DRY and simple to extend. This workshop is a refactor kata taking a bloated sample spec and making it manageable, readable and concise."
    'andrew_weiss':   d: '!Thu, 21st Aug 17:00 GMT', n: 'Andrew Weiss', c: "Consultant at Mircrosoft", t: "Cross-Platform Configuration w PowerShell", in: 'sy5n2q8o2i49/KhUQbZLqfq', tags: ['powershell'], u: 'andrew_weiss', g: '487151c85bfb33f3249c5668874719d2', a: "Join me for a crash course in PowerShell and its configuration management capabilities. In this session, you’ll learn how PowerShell can be used to create consistent, Windows and Linux based development environments. We’ll also explore some of the fundamentals of the popular application distribution system known as Docker and how we can use PowerShell to provision and manage our Docker hosts."
    'al_the_x':       d: '!Thu, 21st Aug 22:00 GMT', n: 'David Rogers', c: "Conference Speaker", t: "Just Enough ReST with<br /> Google App Engine", in: 'sy5n2q8o2i49/yTIUuanj7P', tags: ['google-app-engine','python'], u: 'al_the_x', g: '29c8aeb1641fdd7ac14fd94d4f874e26', a: "Description coming soon"
    'amirrajan':      d: 'Fri, 22nd Aug 15:00 GMT', n: 'Amir Rajan', c: "Apple Design Award Winner", l: "Beginner", t: "How to Con Your Way to <br />App Store #1", tw: 'ADarkRoomiOS', tags: ['app-store'], u: 'amirrajan', g: '433d6daba7a9f7e563b793c0890ef906', a: "What does it take to climb your way to the top spot in the App Store? What kind of revenue can you expect from building for-pay iOS apps? How does news coverage and social media affect download rates? Amir Rajan, creator of the A Dark Room iOS, will share the wisdom he's gained from climbing to the #1 spot. He'll share revenue and provide insight into the ranking system. He'll talk about pricing strategies, combating clones, dealing with negative reviews, and what control you have (and don't have) if your app goes viral.", b: "Amir Rajan is a jack of all trades. He has expertise in a number languages (C#, F#, Ruby, Scala, JavaScript, and Objective C). He is also the creator of A Dark Room iOS. This minimalist text based RPG conquered the world and took the #1 spot in the App Store across 5 countries. This chart topping iOS game and its unprecedented rise to the top has received critical acclaim from Paste Magazine, Giant Bomb, Forbes, The Huffington Post, Cult of Mac, and The New Yorker."
    'basarat':        d: 'Fri, 22nd Aug 22:00 GMT', n: 'Basarat Ali', c: "Typescript Top Answerer", t: "Prototypal Inheritance<br /> in JavaScript", so: '390330/basarat', tags: ['javascript'], u: 'basarat', g: '1400be56ff17549b926dd3260da4a494', a: "No part of JavaScript is more misunderstood than its Prototypal inheritance. This presentation explains the behavior and usefulness of <code>this</code> and continues on to simplify Prototypal inheritance for the masses."
    'mariovisic':     d: 'Sat, 23rd Aug 23:00 GMT', n: 'Mario Visic', c: "Conference Speaker", t: "ActiveRecord without active record", u: 'mariovisic', tw: 'mariovisic', tags: ['rails','activerecord'], g: 'db58858a009745e96871e04ef497269a', a: "An exercise in using the popular and well maintained ActiveRecord library in a web application while avoiding the active record pattern."
    'larskotthoff':   convert 'larskotthoff', 'quickstart-to-d3js', so: '1172002/lars-kotthoff'
    'fluffyjack':     d: '!Sun, 24th Aug 22:00 GMT', n: 'Jack Watson-Hamblin', c: "RubyMotion Screencaster", t: "Is swift that <br />Swift?", in: 'sy5n2q8o2i49/oNxzjUMtdW', tags: ['swift'], u: 'fluffyjack', g: '7a26ff0ae0b5e31a737ab8e4c887f0cf', a: "Swift is a whole new world of possibilities. Be shown through how Swift makes a difference, whether it's production ready or not, and what some of the game changing features are."
    'urish':          d: 'Mon, 25th Aug 17:00 GMT', n: 'Uri Shaked', c: "AngularJS Google Developer Expert", t: "Avoiding Common Pitfalls <br />in AngularJS", in: 'sy5n2q8o2i49/H_-Va_zs6e', tags: ['angularjs'], u: 'urish', g: '11696d5a1b7da83ebdf9c54a5dbd8f7a', a: "The things I wish someone told me when I started developing with Angular.JS. We will explore the Best practices as well Anti-Patterns every Angular.JS developer should be aware of."
    'antonioribeiro': d: 'Mon, 25th Aug 21:00 GMT', n: 'Antonio Carlos Ribeiro', c: "All-time Laravel #1 Answerer", t: "Crafting Applications and Composer Packages", so: '1959747/antonio-carlos-ribeiro', tags: ['php','laravel'], u: 'antonioribeiro', g: 'ce2a78842d9de0c9ab48e4ed3c473b3e', a: "Reduce coupling, expunge repetition, and effectively increase your reusable codebase through the creation and use of Composer packages in PHP and Laravel applications."
    '2upmedia':       d: 'Tue, 26th Aug 18:00 GMT', n: 'Jorge Colon', c: "PHP Wiz kiz", t: "Emulate staging servers w <br />Vagrant, CentOS & LAMP", in: 'sy5n2q8o2i49/cPXFL7mBie', tags: ['vagrant','centos','lamp'], u: '2upmedia', g: 'b93914137ae67057880798210dc80e20', a: "Some developers still use FTP and a live server, some have graduated to running a development environment locally, but the savvy emulate the live server locally with a virtual server. Vagrant makes this so easy. We'll go through how to install Vagrant, configuring a basic Vagrant configuration, then install LAMP on CentOS."
    'auser':          d: '!Thu, 28th Aug 16:00 GMT', n: 'Ari Lerner', c: "ng-newsletter Creator", t: "Powering interfaces <br />with AngularJS", u: 'auser', gh: 'auser', tags: ['angularjs'], g: '0ec7fe2c17900b71bd85ff63fc9d8a17', a: "Ari is a co-author of The Rails 4 Way, Riding Rails with AngularJS and the Beginner’s Guide to AngularJS. Recently Ari has been training folks in AngularJS at Hack Reactor as a JavaScript teacher. Ari also publishes ng-newsletter.com."
    'kn0tch':         d: 'Thu, 28th Aug 22:00 GMT', n: 'Greg Osuri', c: "Mr Awesome", t: "Containerizing Production Applications", tw: 'kn0tch', tags: ['aws','infrastructure'], u: 'kn0tch', g: '9c6165b107059ea5dfa2e81985fe8272', a: "The advent of new Linux container technology is changing the landscape of deployment and improving scalability and performance. This presentation will explain how to implement the right architecture and deployment workflow, which is crucial to fully realizing the benefits of containers"
    'abeisgreat':     d: '!Sat, 30th Aug 16:00 GMT', n: 'Abe Haskins', c: "Angularfire Contributor", t: "Fast Client-Side Apps w AngularFire", gh: 'abeisgreat', tags: ['firebase','angularjs'], u: 'abeisgreat', g: 'fbb79df0f24e736c8e37f9f195a738cc', a: "Description coming soon"
    'ronlichty':      d: '!Sat, 30th Aug 22:00 GMT', n: 'Ron Lichty', c: "Agile Book Author", t: "Crash Course: Managing Software People and Teams", tw: 'ronlichty', tags: ['agile','extreme-programming'], u: 'ronlichty', g: '4974bd42e635147b1fee8323f122acc9', a: "Description coming soon"
    'mikegrassotti':  d: '!Sun, 31st Aug 16:00 GMT', n: 'Michael Grassotti', c: "All-time Ember.js #1 Answerer", t: "Something<br />Ember.js", so: '983357/mike-grassotti', tags: ['ember.js'], u: 'mikegrassotti', g: '9b9536f792ccd2b3641d8e3f9a157167', a: "Description coming soon"
    'mfeckie':        d: '!Sun, 31st Aug 23:00 GMT', n: 'Martin Feckie', c: "Ember.js Book Author", t: "TDD Ember.js<br /> for Beginners", so: '1849245/muttonlamb', tags: ['ember.js','tdd'], u: 'mfeckie', g: 'c247d50c623c3bf6257ad11e08f732f1', a: "Description coming soon"
    'u':              d: '', n: '', c: "", t: "", in: '', tags: [''], u: '', g: '', a: ""
    'count':          60

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
