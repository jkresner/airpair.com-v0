addjsevents = {}


addEvent = (category, name, uri, qty, qtyFreq, desc) ->
  addjsevents[name] = { category, name, uri, qty, qtyFreq, desc }

addEvent 'landing-ad-go', 'stack-overflow', '/help-with-rails', 100, 'week', 'customer lands on a so rails landing page'

addEvent 'landing-ad-so', 'rails-help', '/help-with-rails', 100, 'week', 'customer lands on a so rails landing page'

addEvent 'landing', 'pair-programming', '/pair-programming', 100, 'week', 'customer lands on a landing page'

addEvent 'request', 'customerWelcome', '/find-an-expert', 100, 'week', 'customer creates account via google login'

addEvent 'request', 'customerLogin', '/find-an-expert', 100, 'week', 'customer tried to login via google'

addEvent 'request', 'customerSignup', '/find-an-expert', 100, 'week', 'customer creates account via google login'

addEvent 'request', 'customerInfoNew', '/find-an-expert/info', 90, 'week', 'customer saves contact info first time'

addEvent 'request', 'customerRequest', '/find-an-expert/request', 50, 'week', 'customer saves contact info first time'

addEvent 'request', 'customerEmailConfirm', '/find-an-expert/confirm', 50, 'week', 'customer confirms their contact email is correct'

addEvent 'request', 'customerTryPayPaypal', '/review', 50, 'week', 'customer hit the pay button with paypal'

addEvent 'request', 'customerTryPayStripe', '/review', 50, 'week', 'customer hit the confirm button with stripe'

addEvent 'request', 'customerOrderCreated', '/review', 50, 'week', 'order was successfully created'

addEvent 'request', 'customerPayment', '/review/*', 50, 'week', 'customer paid with paypal'

addEvent 'beexpert', 'expertWelcome', '/be-an-expert', 100, 'week', 'expert creates account via google login'

addEvent 'beexpert', 'expertLogin', '/be-an-expert', 100, 'week', 'expert tried to login via google'

addEvent 'beexpert', 'expertSignup', '/be-an-expert', 100, 'week', 'expert creates account via google login'

addEvent 'beexpert', 'expertConnect', '/be-an-expert/', 90, 'week', 'expert saves contact info first time'

addEvent 'beexpert', 'expertInfo', '/be-an-expert/in', 50, 'week', 'customer saves contact info first time'

addEvent 'bookView', 'bookView', '/@*', 50, 'week', 'customer viewed expert book'

module.exports = addjsevents
