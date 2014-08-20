DomainService = require './_svc'
EmailTemplatesService = require './../services/emailTemplates'

Order = require '../models/order'
OrdersService = require './orders'
OrdersQuery = require './orders.query'

Workshop = require '../models/workshop'
WorkshopsQuery = require './workshops.query'

allWorkshops = {}

module.exports = class WorkshopsService extends DomainService

  model: Workshop

  constructor: (user) ->
    @ordersService = new OrdersService(user)
    @emailTemplatesService = new EmailTemplatesService user
    super user

  getAllRegisteredAirconfUsers: (callback) =>
    Workshop.find().populate('attendees.userId').lean().exec (error, workshops) ->
      attendees = {}
      _.each workshops, (w) ->
        _.each w.attendees, (attendee) ->
          user = attendee.userId
          if user.google? and user.google._json?
            attendees[user.google._json.email] ||= []
            attendees[user.google._json.email].push(w.slug)

      query = Order.find(requestId: OrdersQuery.airconf.requestId)
      query.populate('userId').lean().exec (error, orders) ->
        users = _.map orders, (order) ->
          date: order.utc
          name: order.userId?.google?.displayName
          company: order.company?.name
          email: order.userId?.google?._json.email
          gplus: order.userId?.google?._json.link
          picture: order.userId?.google?._json.picture
          revenue: order.profit
          rsvpCount: attendees[order.userId?.google?._json.email]?.length or 0
          rsvpSessions: attendees[order.userId?.google?._json.email]?.join(',') or ""

        callback(null, _.flatten(users))

  getAllCached: (callback) =>
    callback(null, allWorkshops)

  getAttendeesBySlug: (slug, callback) =>
    Workshop.findOne(slug: slug).populate('attendees.userId').lean().exec (error, workshop) ->
      if error then return callback(error)

      attendees = _.map(workshop?.attendees or [], (attendee) ->
        id: attendee.userId.google._json.id
        name: attendee.userId.google._json.name
        picture: attendee.userId.google._json.picture
      )
      callback error, attendees

  getWorkshopBySlug: (slug, callback) ->
    query = slug: slug
    @searchOne query, WorkshopsQuery.view.public, (error, workshop) ->
      callback error, workshop

  getWorkshopsByTag: (tag, callback) ->
    query = tags: tag
    @searchMany query, WorkshopsQuery.view.public, (error, workshop) ->
      callback error, workshop

  getListByAttendee: (userId, callback) ->
    query = attendees:
      $elemMatch:
        userId: userId
    @searchMany query, WorkshopsQuery.view.public, (err, workshops) ->
      callback(err, workshops)

  addAttendee: (slug, userId, callback) ->
    isAdminRequest = userId?
    userId ?= @usr._id
    email = @usr.google._json.email
    query = slug: slug
    @searchOne query, {}, (err, workshop) =>
      # something went wrong, abort
      if !workshop? or err?
        return callback(err, {})

      # don't dupe RSVPs. Front end does that sometimes
      if _.find(workshop.attendees, (a) -> a.userId is userId)
        return callback(null, workshop)

      orderQuery =
        userId: userId
        requestId: OrdersQuery.airconf.requestId

      @ordersService.searchOne orderQuery, {}, (err, order) =>
        if err? then callback(err, {})
        if order?
          attendee =
            userId: userId
            orderId: order._id
          workshop.attendees ?= []
          workshop.attendees.push(attendee)
          @update workshop._id, workshop, (workshopErr, workshop) =>
            if isAdminRequest
              callback(workshopErr, workshop)
            else
              @emailTemplatesService.send OrdersQuery.airconf.requestId, {workshop, to: email}, (err, template) =>
                callback(workshopErr, workshop)
        else
          callback(err, {success: false, message: "Order not found"})

setWorkshopCache = _.once (service) ->
  service.searchMany {}, WorkshopsQuery.view.public, (err, workshops) ->
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

