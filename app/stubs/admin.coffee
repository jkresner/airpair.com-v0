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


# Companies
bryan_hughes = aContact 5322, 'Bryan Hughes', 'Founder', 'rbhughes@logicalcat.com', '303-949-8125'
logicalCat = aCompany 10, 'LogicalCat', 'www.logicalcat.com', [bryan_hughes], "LogicalCat is a niche search engine and reporting tool for oil & gas exploration data. Users tend to be technicians or IT folks with the unpleasant task of sifting through potentially millions of messy files. The online app is just a demo; the real thing runs on user's intranets (because oil companies are paranoid), usually 100% Windows."

# Lead Status
# 1) Prospect (Missing about company / brief)
# 2)

# suggestion statuses :
# waiting, willing, accepted

logicalCatSuggested = [
  aSuggestion 1211211, @focusaurus, d.feb15, d.feb17, 'willing', 'Evenings Feb 20-23'
]


@stubs.admin.leads = [
  aLead 2101, d.feb15, 'open', logicalCat, logicalCat.contacts, [@bdd, @crawler, @express, @node, @ror, @javascript, @windows], briefs.logicalCat, logicalCatSuggested, []
]