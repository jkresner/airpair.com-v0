DomainService = require './_svc'
OrdersService = require './../services/orders'

module.exports = class WorkshopsService extends DomainService

  model: require './../models/workshop'
  data: require './workshops.query'
  orderData: require './orders.query'

  constructor: (user) ->
    @ordersService = new OrdersService user
    super user

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

