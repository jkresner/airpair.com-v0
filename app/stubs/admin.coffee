briefs = require './briefs'
d = @stubs.dates
@stubs.admin = {}

aCompany = (id, name, url, contacts, about) ->
  id:           id
  name:         name
  url:          url
  contacts:     contacts
  about:        about

aContact = (id, name, title, email, phone) ->
  id:           id
  name:         name
  title:        title
  email:        email
  phone:        phone

aSuggestion = (id, dev, contacted, responded, status, availabilty) ->
  id:           id
  dev:          dev
  contacted:    contacted
  responded:    responded
  status:       status
  availabilty:  availabilty

aCall = (id, dev, time, recordingId, review, cost, comission) ->
  id:           id
  dev:          dev
  time:         time
  recordingId:  recordingId
  review:       review
  cost:         cost
  comission:    comission

aLead = (id, created, status, company, contacts, skills, brief, suggested, calls) ->
  id:           id
  created:      created
  status:       status
  company:      company
  contacts:     contacts
  skills:       skills
  brief:        brief
  suggested:    suggested
  calls:        calls

@stubs.admin.leads = []


# Companies
bryan_hughes =    aContact 5322, 'Bryan Hughes', 'Founder', 'rbhughes@logicalcat.com', '303-949-8125'
logicalCat =      aCompany 10, 'LogicalCat', 'www.logicalcat.com', [bryan_hughes], "LogicalCat is a niche search engine and reporting tool for oil & gas exploration data. Users tend to be technicians or IT folks with the unpleasant task of sifting through potentially millions of messy files. The online app is just a demo; the real thing runs on user's intranets (because oil companies are paranoid), usually 100% Windows."
logicalCatSuggested = [
  aSuggestion 1211211, @focusaurus, d.feb15, d.feb17, 'chosen', 'Evenings Feb 20-23'
  aSuggestion 1211211, @arieljake, d.feb17, d.feb17, 'interested', 'Finding out...'
  aSuggestion 1211211, @raynos, d.feb15, d.feb18, 'interested', 'Finding out...'
]
logicalCatCalls = [
  aCall 211211211, @focusaurus, 'Wed 20 6:30PM PST', '-', {}, 40, 10
  aCall 211211211, @focusaurus, 'Sat 23 8:00PM PST', '-', {}, 140, 20
]


chris_hexton =    aContact 5422, 'Chris Hexton', 'Co-Founder', 'chris@getvero.com', '0422 723 190'
james_lamont =    aContact 5423, 'James Lamont', 'Co-Founder/CTO', 'james@getvero.com', '02 8005 1556'
vero =            aCompany 11, 'Vero', 'www.getvero.com', [chris_hexton,james_lamont], "Vero is 10 months old. We do lifecycle/behavioral emails. Most of our customers are eCommerce or SaaS businesses. We collect data on events a bit like Google Analytics and then make it easy for the customers to build emails inside our app (think Mailchimp). When conditions are met we spew emails out the other side. As such the app has to be up ALL THE TIME (near as) and it's getting pretty involved… which makes it awesome fun."
veroSuggested = [
  aSuggestion 1311211, @jmontross, d.feb18, null, 'waiting', '-'
  aSuggestion 1311221, @gosuri, d.feb18, null, 'waiting', '-'
]
veroCalls = [ ]

charles_worthington = aContact 5522, 'Charles Worthington', 'Founder', 'charles@grayducklabs.com', '617 899 7854'
simply3 =             aCompany 12, 'Simply3', '', [charles_worthington], "Simply3 is an commerce website. Essentially it is a front-end to Amazon.com that aims to simplify shopping decisions by limiting the number of products shown in a given category to just three pre-screened choices."
simply3Suggested = [ ]
simply3Calls = [ ]


taariq_lewis  =   aContact 5622, 'Taariq Lewis ', 'Founder', 'taariq.lewis@gmail.com', '-'
simon_frid =      aContact 5623, 'Simon Frid', 'Lead Dev', 'simonfrid@gmail.com', '-'
orb =             aCompany 13, 'Orb', 'www.getvero.com', [taariq_lewis,simon_frid], " We are Orb. We're a new type of closed group platform for groups that we call Orbs."
orbSuggested = []
orbCalls = [ ]

# Companies
kavin_stewart =   aContact 5721, 'Kavin Stewart', 'Founder', 'kavin.stewart@gmail.com', '-'
grumbleBeans =     aCompany 14, 'Grumble Beans Tea & Spices', null, [kavin_stewart], "I'm Kavin Stewart. I'm a second time entrepreneur. Previously co-founder / CEO / VP Product at Lolapps, a social gaming company. Currently hacking away on some ideas in the photos space. I'm interested in understanding simple things like how to properly access photos across different Android versions and devices. I'm keen on some mentoring and help getting un-stuck with problems"
grumbleBeansSuggested = [
  aSuggestion 1213211, @khanmurtuza, d.mar06, '-', 'waiting', 'Finding out...'
  aSuggestion 1213213, @ashokvarma2, d.mar06, '-', 'waiting', 'Finding out...'
  aSuggestion 1213214, @justinlloyd, d.mar06, '-', 'waiting', 'Finding out...'
  aSuggestion 1213215, @sweetleon, d.mar06, '-', 'waiting', 'Finding out...'
]
grumbleBeansCalls = [ ]

# Lead Status
# 1) Prospect (Missing about company / brief)
# 2)

# suggestion statuses :
# waiting, willing, accepted

@stubs.admin.leads = [
  aLead 2101, d.feb10, 'open', vero, vero.contacts, [@bdd, @ror], briefs.vero, veroSuggested, veroCalls
  aLead 2112, d.feb15, 'closed', logicalCat, logicalCat.contacts, [@bdd, @crawler, @express, @node, @ror, @javascript, @windows], briefs.logicalCat, logicalCatSuggested, logicalCatCalls
  aLead 2122, d.feb15, 'open', simply3, simply3.contacts, [@ror], briefs.simply3, simply3Suggested, simply3Calls
  aLead 2132, d.mar01, 'stale', orb, orb.contacts, [@python], briefs.orb, orbSuggested, orbCalls
  aLead 2142, d.mar01, 'open', grumbleBeans, grumbleBeans.contacts, [@android], briefs.grumbleBeans, grumbleBeansSuggested, grumbleBeansCalls
]