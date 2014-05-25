HipChatter = require 'hipchatter'


module.exports = class HipChatService

  constructor: (token) ->
    @token = token
    @HC = new HipChatter(token)
    # @HC.capabilities (err, r) => $log(r.capabilities.hipchatApiProvider)

  createUser: (data, callback) =>
    $log 'createHipChatUser', data
    @HC.create_user data, (e, r) =>
      $log 'e', e, 'r', r
      callback e, r

  createRoom: (ownerEmail, roomData, callback) =>
    roomData.privacy = "private"
    roomData.owner_user_id = ownerEmail

    @HC.create_room roomData, (e, r) =>
      callback e, r


  addMember: (room_name, user_email, callback) =>
    @HC.add_member {room_name,user_email}, (e, r) =>
      $log 'user_email', user_email, 'e', e, 'r', r
      callback e, r


  sendMsg: (roomId, message, message_format, callback) =>
    notify = true
    @HC.notify roomId, {message,message_format,notify,@token}, callback


  getUsers: (emails, callback) =>

    $log 'getUsers', emails
    @HC.users (e, r) =>
      $log 'e', e, 'r', r
      for user in r
        $log user
      callback e, r


  getUserByEmailOrName: (email, name, callback) =>
    @HC.view_user email, (e, r) =>
      if !e? then return callback null, r
      @HC.view_user '@'+name.replace(' ',''), callback

  # getRooms: (admin) ->
  #   @HC.rooms (data) ->
  #     $log data

