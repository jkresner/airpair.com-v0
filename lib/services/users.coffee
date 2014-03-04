User  = require '../models/user'
panel = require './wrappers/mixpanel'

module.exports = class UsersService

  mixpanelData: (userId, cb) ->
    User.findById(userId).lean().exec (err, user) =>
      if !user?.cohort?.mixpanel?.data
        return @_importFromMixpanel user, cb
      cb null, user

  _importFromMixpanel: (user, cb) ->
    panel.eventsFor user.google._json.email, (err, data) =>
      if err then return cb err
      data = panel.sanitizeForMongo(data)
      mixpanelId = panel.firstEvent(data).properties.distinct_id
      ups = $set:
        'cohort.mixpanel.id': mixpanelId
        'cohort.mixpanel.data': data

      User.findByIdAndUpdate(user._id, ups).lean().exec cb

  saveUtm: (userId, utm, cb) ->
    ups = 'cohort.mixpanel.utm': utm
    User.findByIdAndUpdate(userId, ups).lean().exec cb
