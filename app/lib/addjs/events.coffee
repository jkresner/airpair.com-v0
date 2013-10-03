addjsevents = {}


addEvent = (category, name, uri, qty, qtyFreq, desc) ->
  addjsevents[name] = { category, name, uri, qty, qtyFreq, desc }

addEvent 'landing', 'pair-programming', '/pair-programming', 100, 'week', 'customer lands on a landing page'

addEvent 'request', 'customerSignup', '/find-an-expert', 100, 'week', 'customer creates account via google login'

addEvent 'request', 'customerInfo', '/find-an-expert/info', 90, 'week', 'customer saves contact info first time'

addEvent 'request', 'customerRequest', '/find-an-expert/request', 50, 'week', 'customer saves contact info first time'


module.exports = addjsevents