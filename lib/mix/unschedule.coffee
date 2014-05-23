idsEqual = require './idsEqual'

# takes a set of orders, and removes the given callId from all redeemedCalls
# arrays on the lineItems.
# What does this really do? It makes it as though the given call never existed;
# this allows us to schedule the call again (this happens during the edit
# process). "Editing" a call is really just deleting all traces of it from the
# orders (this function) and then scheduling it anew. This let's us reuse a
# bunch of functions.
module.exports =
unschedule = (orders, callId) ->
  orders.map (o) ->
    o.lineItems = o.lineItems.map (li) ->
      li.redeemedCalls = _.reject li.redeemedCalls, (rc) ->
        idsEqual rc.callId, callId
      li
    o
