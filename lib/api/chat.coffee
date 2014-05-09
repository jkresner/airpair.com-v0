Api         = require './_api'
ChatSvc     = require './../services/chat'


class ChatApi extends Api

  # svc: new ChatSvc()

  setSvc: (req, res, next) =>
    @svc = new ChatSvc req.user
    next()

  routes: (app, route) ->
    app.get     "/api/#{route}/rooms/:cId", @admin, @setSvc, @getCompanyRooms
    app.get     "/api/#{route}/users/:id", @admin, @setSvc, @getUserByEmail
    app.post    "/api/#{route}/rooms", @admin, @setSvc, @createRoom
    app.post    "/api/#{route}/users", @admin, @setSvc, @createUser
    # app.delete  "/api/#{route}/users/:id", @admin, @deleteUser
    # app.delete  "/api/#{route}/rooms/:id", @admin, @deleteRoom


  createRoom: (req, res, next) =>
    @svc.createRoom req.user, req.body, @cSend(res, next)


  createUser: (req, res, next) =>
    @svc.createUser req.body, @cSend(res, next)


  getCompanyRooms: (req, res, next) =>
    @svc.getCompanyRooms req.params.cId, @cSend(res, next)


  getUserByEmail: (req, res, next) =>
    @svc.getUserByEmail req.params.id, @cSend(res, next)


  # getUsersByEmail: (req, res, next) =>
  #   userEmails = _.pluck req.users, 'email'
  #   @svc.getUsersByEmail userEmails cSend(res, next)

  # delete: (req, res, next) =>
  #   @svc.delete req.params.id, cSend(res, next)


module.exports = (app) -> new ChatApi app, 'chat'
