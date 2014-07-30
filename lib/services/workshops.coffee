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
    console.log "query", query
    @searchMany query, @data.view.public, (err, workshops) ->
      callback(err, workshops)


  addAttendee: (id, userId, requestId, callback) ->
    userId = @usr._id unless userId?
    query = _id: id
    @searchOne query, @data.view.public, (err, workshop) =>
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
          console.log "workshop", workshop
          workshop.attendees ?= []
          workshop.attendees.push(attendee)
          @update(id, workshop, callback)
        else
          callback(err, order)

