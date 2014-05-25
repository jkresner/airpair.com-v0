
class ChatApi extends require('./_api')

  Svc: require './../services/chat'

  routes: (app, route) ->
    app.get     "/api/#{route}/rooms/:cId", @admin, @ap, @getCompanyRooms
    app.get     "/api/#{route}/users/:email/:name", @admin, @ap, @getUser
    app.post    "/api/#{route}/rooms", @admin, @ap, @createRoom
    app.post    "/api/#{route}/users", @admin, @ap, @createUser
    app.post    "/api/#{route}/msg", @admin, @ap, @sendMsg
    app.put     "/api/#{route}/rooms/:id", @admin, @ap, @updateRoom
    # app.delete  "/api/#{route}/users/:id", @admin, @deleteUser
    # app.delete  "/api/#{route}/rooms/:id", @admin, @deleteRoom


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


module.exports = (app) -> new ChatApi app, 'chat'
