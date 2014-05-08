HipChatter = require 'hipchatter'


module.exports = class HipChatService

  constructor: () ->

    # todo figure out the token situation

    @HC = new HipChatter(cfg.hipChat.tokens['jk'])
    @HC.capabilities (err, r) =>

    # $log(r.capabilities.hipchatApiProvider)

  createRoom: (ownerEmail, roomData, callback) =>
    roomData.privacy = "private"
    roomData.owner_user_id = ownerEmail

    @HC.create_room roomData, (e, r) =>
      $log 'e', e, 'r', r
      callback e, r


  addMember: (room_name, user_email, callback) =>
    @HC.add_member {room_name,user_email}, (e, r) =>
      $log 'user_email', user_email, 'e', e, 'r', r
      callback e, r

  createUser: (data, callback) =>

    $log 'createHipChatUser', data
    @HC.create_user data, (e, r) =>
      $log 'e', e, 'r', r
      callback e, r


  getUsers: (emails, callback) =>

    $log 'getUsers', emails
    @HC.users (e, r) =>
      $log 'e', e, 'r', r
      for user in r
        $log user
      callback e, r


  getUserByEmail: (email, callback) =>

    # $log 'getUser', email
    @HC.view_user email,  (e, r) =>
      if e?
        $log 'view_user', e
        callback null, { mention_name: '-' }
      else
        callback null, r


  # getRooms: (admin) ->

  #   HC.rooms (data) ->
  #     $log data

