HipChatter = require 'hipchatter'

HC = new Hipchatter(config.hipChat.tokens['jk'])


module.exports = class HipChatService


  createRequestRoom: (admin, request, callback) ->
    name = "test req"
    privacy = "privat"
    owner_user_id = "#{admin}@airpair.com"

    HC.create_room { name, privacy, owner_user_id }, (e, r) =>
      console.log 'e', e, 'r', r


  # getRooms: (admin) ->

  #   HC.rooms (data) ->
  #     $log data

