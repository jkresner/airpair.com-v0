# {http,_,sinon,chai,expect} = require '../test-lib-setup'
# {app, data}                = require '../test-app-setup'

# user = data.users[13]  # bchristie

# cloneDeep = require 'lodash.cloneDeep'
# ObjectId = require('mongoose').Types.ObjectId

# svc = new (require '../../../lib/services/orders')(user)

# describe 'AirConfOrdersService', ->

#   it "can order airconf without coupon", ->
#     svc.settingsSvc.getByUserId = (userId, cb) ->
#       cb null, paymentMethods: [
#         {
#           type: 'stripe',
#           info:
#             livemode: false,
#             id: 'cus_4S7qJ1OyYNqC7W'
#             created: 1406075235,
#             object: 'customer'
#           isPrimary: false,
#           _id: '53b5ad6f69548e0200ee8018'
#         }
#       ]

#     svc.createAirConfOrder { total: 150 }, (e, r) ->
#       $log 'got ya order boss', r

#       expect(true).to.equal false


