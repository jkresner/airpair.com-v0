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
    @searchOne query, @data.view.public, (err, workshop) =>
      callback(err, workshop) unless workshop?
      if err? then callback(err, workshop)
      orderQuery =
        userId: userId
        requestId: requestId

      @ordersService.searchOne orderQuery, {}, (err, order) =>
        if err? then callback(err, workshop)
        if order?
          attendee =
            userId: userId
            orderId: order._id
          workshop.attendees ?= []
          workshop.attendees.push(attendee)
          @update(workshop._id, workshop, callback)
        else
          callback(err, order)

setWorkshopCache = _.once (service)->
    service.getAll (err, workshops) ->
      if err? then callback(err, workshops)
      moment = require('moment-timezone')
      enhancedWorkshops = _.map workshops, (workshop) ->
        workshop.calutc = moment(workshop.time).tz('Etc/GMT+3').format('YYYYMMDDTHHmmss') + "Z"
        workshop.calend = moment(workshop.time).tz('Etc/GMT+2').format('YYYYMMDDTHHmmss') + "Z"
        # subtract a day so week starts on monday
        workshop["WK" + moment(workshop.time).subtract('days', 1).format("ggggww")] = true
        workshop
      allWorkshops = _.sortBy enhancedWorkshops, (workshop) ->
        moment(workshop.time).format("YYYYMMDDTHHmmss")
      allWorkshops.count = 80
setWorkshopCache(new WorkshopsService)

