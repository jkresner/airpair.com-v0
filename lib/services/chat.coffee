DomainService = require './_svc'
HC = require './wrappers/hipchat'
RequestSevice = require './requests'

module.exports = class ChatService extends DomainService

  logging: on

  room: require './../models/room'
  rSvc: new RequestSevice()

  constructor: (user) ->
    admin = user.google._json.email.split('@')[0]
    token = cfg.hipChat.tokens[admin];
    $log 'ChatService', user.google._json.email, admin, token
    @hc = new HC token


  createRoom: (user, data, callback) =>
    @hc.createRoom user.google._json.email, data, (e, r) =>
      if e? then callback e, r

      $log 'room.created', r.id, e, r
      for m in data.members
        @hc.addMember data.name, m.email, ->

      data.hipChatId = r.id
      data.status = 'active'
      new @room(data).save (ee,rr) ->
        $log 'room.collection,save', rr
        callback ee, rr


  createUser: (chatUser, callback) =>
    @hc.createUser chatUser, callback


  getCompanyRooms: (companyId, callback) ->
    @room.find({ companyId }).lean().exec callback

  # getRoom: (admin, companyId, expertUId, callback) ->
  #   @room.findOne({ customerUId, expertUId }).lean().exec (e,r) =>
  #     if r?
  #       callback r
  #     else
  #       createRoom { customerUId, expertUId }, callback

  #     new @model({ admin, customerUId, expertUId }).save callback


  getUsersByEmail: (emails, callback) ->
    @hc.getUsers emails, callback


  getUserByEmail: (email, callback) ->
    @hc.getUserByEmail email, callback
