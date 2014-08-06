DomainService = require './_svc'
OrdersService = require './../services/orders'

allWorkshops = {}

module.exports = class WorkshopsService extends DomainService

  model: require './../models/workshop'
  data: require './workshops.query'
  orderData: require './orders.query'

  constructor: (user) ->
    @ordersService = new OrdersService user
    super user

  getAllCached: (callback) =>
    callback(null, allWorkshops)

  getAttendeesBySlug: (slug, callback) =>
    @model.findOne(slug: slug).populate('attendees.userId').lean().exec (error, workshop) ->
      if error then return callback(error)

      attendees = _.map(workshop?.attendees or [], (attendee) ->
        name: attendee.userId.google._json.name
        picture: attendee.userId.google._json.picture
      )
      callback error, attendees

  getWorkshopBySlug: (slug, callback) ->
    query = slug: slug
    @searchOne query, @data.view.public, (error, workshop) ->
      callback error, workshop

  getListByAttendee: (userId, callback) ->
    userId = @usr._id unless userId?
    query = attendees:
      $elemMatch:
        userId: userId
    @searchMany query, @data.view.public, (err, workshops) ->
      callback(err, workshops)

  addAttendee: (slug, userId, requestId, callback) ->
    userId = @usr._id unless userId?
    query = slug: slug
    @searchOne query, {}, (err, workshop) =>
      callback(err, {}) unless workshop?
      if err? then callback(err, {})
      orderQuery =
        userId: userId
        requestId: requestId

      @ordersService.searchOne orderQuery, {}, (err, order) =>
        if err? then callback(err, {})
        if order?
          attendee =
            userId: userId
            orderId: order._id
          console.log workshop
          workshop.attendees ?= []
          workshop.attendees.push(attendee)
          @update(workshop._id, workshop, callback)
        else
          callback(err, {success: false, message: "Order not found"})

setWorkshopCache = _.once (service)->
    data = require './workshops.query'
    service.searchMany {}, data.view.public, (err, workshops) ->
      if err? then callback(err, workshops)
      moment = require('moment-timezone')
      enhancedWorkshops = _.map workshops, (workshop) ->
        # subtract a day so week starts on monday
        workshop["WK" + moment(workshop.time).subtract('days', 1).format("ggggww")] = true
        workshop
      allWorkshops = _.sortBy enhancedWorkshops, (workshop) ->
        moment(workshop.time).format("YYYYMMDDTHHmmss")
      allWorkshops.count = 80
setWorkshopCache(new WorkshopsService)

