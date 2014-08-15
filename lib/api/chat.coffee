class ChatApi extends require('./_api')

  Svc: require './../services/chat'

  routes: (app) ->
    app.get  "/chat/rooms/:cId", @admin, @ap, @getCompanyRooms
    app.get  "/chat/users/:email/:name", @admin, @ap, @getUser
    app.post "/chat/rooms", @admin, @ap, @createRoom
    app.post "/chat/users", @admin, @ap, @createUser
    app.post "/chat/msg", @admin, @ap, @sendMsg
    app.put  "/chat/rooms/:id", @admin, @ap, @updateRoom

  createRoom: (req, res, next) =>
    @svc.createRoom req.user, req.body, (e, r) =>
      if e?
        @tFE res, 'Room creation', 'roomName', e
      else
        @cSend(res, next)(e,r)

  createUser: (req) => @svc.createUser req.body, @cbSend
  sendMsg: (req) => @svc.sendMsg req.body, @cbSend
  getCompanyRooms: (req) => @svc.getCompanyRooms req.params.cId, @cbSend
  getUser: (req) => @svc.getUser req.params.email, req.params.name, @cbSend
  updateRoom: (req) => @svc.updateRoom req.params.id, req.body, @cbSend

  # delete: (req) => @svc.delete req.params.id, @cbSend


module.exports = (app) -> new ChatApi(app)
