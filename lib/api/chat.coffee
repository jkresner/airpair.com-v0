Api         = require './_api'
ChatSvc     = require './../services/chat'


class ChatApi extends Api

  # logging: on

  # svc: new ChatSvc()

  setSvc: (req, res, next) =>
    @svc = new ChatSvc req.user
    next()

  routes: (app, route) ->
    app.get     "/api/#{route}/rooms/:cId", @admin, @setSvc, @getCompanyRooms
    app.get     "/api/#{route}/users/:email/:name", @admin, @setSvc, @getUser
    app.post    "/api/#{route}/rooms", @admin, @setSvc, @createRoom
    app.post    "/api/#{route}/users", @admin, @setSvc, @createUser
    app.post    "/api/#{route}/msg", @admin, @setSvc, @sendMsg
    app.put     "/api/#{route}/rooms/:id", @admin, @setSvc, @updateRoom
    # app.delete  "/api/#{route}/users/:id", @admin, @deleteUser
    # app.delete  "/api/#{route}/rooms/:id", @admin, @deleteRoom


  createRoom: (req, res, next) =>
    @svc.createRoom req.user, req.body, (e, r) =>
      if e?
        @tFE res, 'Room creation', 'roomName', e
      else
        @cSend(res, next)(e,r)


  createUser: (req, res, next) =>
    @svc.createUser req.body, @cSend(res, next)


  sendMsg: (req, res, next) =>
    @svc.sendMsg req.body, @cSend(res, next)


  getCompanyRooms: (req, res, next) =>
    @svc.getCompanyRooms req.params.cId, @cSend(res, next)


  getUser: (req, res, next) =>
    @svc.getUser req.params.email, req.params.name, @cSend(res, next)


  updateRoom: (req, res, next) =>
    @svc.updateRoom req.params.id, req.body, @cSend(res, next)

  # getUsersByEmail: (req, res, next) =>
  #   userEmails = _.pluck req.users, 'email'
  #   @svc.getUsersByEmail userEmails cSend(res, next)

  # delete: (req, res, next) =>
  #   @svc.delete req.params.id, cSend(res, next)


module.exports = (app) -> new ChatApi app, 'chat'
