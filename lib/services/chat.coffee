DomainService    = require './_svc'
HC               = require './wrappers/hipchat'
RequestSevice    = require './requests'
async            = require 'async'

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
      if e? then return callback e

      $log 'room.created', r.id, e, r
      async.each data.members,
        (m,cb) => @hc.addMember data.name, m.email, cb
        =>
          data.hipChatId = r.id
          data.status = 'active'
          new @room(data).save (ee,rr) ->
            $log 'room.collection,save', rr
            callback ee, rr


  # NOTE this does not update hipChat only associates and de-associates rooms
  updateRoom: (id, data, callback) =>
    ups = _.omit data, '_id' # so mongo doesn't complain
    @room.findByIdAndUpdate(id, ups).lean().exec (e, r) =>
      if e? then return callback e
      callback null, r


  sendMsg: (data, callback) =>
    @hc.sendMsg data.roomId, data.msg, data.format, callback


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


  getUser: (email, name, callback) ->
    @hc.getUserByEmailOrName email, name, callback
