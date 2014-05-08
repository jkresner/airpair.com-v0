Api         = require './_api'
ChatSvc     = require './../services/chat'


class ChatApi extends Api

  svc: new ChatSvc()

  routes: (app, route) ->
    app.get     "/api/#{route}/rooms/:companyId", @admin, @getCompanyRooms
    app.get     "/api/#{route}/users/:id", @admin, @getUserByEmail
    app.post    "/api/#{route}/rooms", @admin, @createRoom
    app.post    "/api/#{route}/users", @createUser

    # app.post    "/api/#{route}", @loggedIn, @create
    # app.put     "/api/#{route}/:id", @loggedIn, @update
    # app.delete  "/api/#{route}/:id", @admin, @delete

  # detail: (req, res, next) =>

  #   search = '_id': req.params.id

  #   if req.params.id is 'me'
  #     search = 'contacts.userId': req.user._id

  #   @svc.searchOne search, cSend(res, next)

  # adminlist: (req, res, next) =>
  #   @svc.getAll cSend(res, next)

  createRoom: (req, res, next) =>
    @svc.createRoom req.user, req.body, @cSend(res, next)

  createUser: (req, res, next) =>
    @svc.createUser req.body, @cSend(res, next)


  # update: (req, res, next) =>
  #   @svc.update req.params.id, req.body, cSend(res, next)

  # delete: (req, res, next) =>
  #   @svc.delete req.params.id, cSend(res, next)

  getCompanyRooms: (req, res, next) =>
    $log 'hello.getCompanyRooms', req.params.companyId
    @svc.getCompanyRooms req.params.companyId, @cSend(res, next)

  # getUsersByEmail: (req, res, next) =>
  #   userEmails = _.pluck req.users, 'email'
  #   @svc.getUsersByEmail userEmails cSend(res, next)


  getUserByEmail: (req, res, next) =>
    @svc.getUserByEmail req.params.id, @cSend(res, next)


module.exports = (app) -> new ChatApi app, 'chat'
