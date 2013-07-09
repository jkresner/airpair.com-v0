DomainService   = require './_svc'
SettingsSvc = require './../services/settings'

module.exports = class SettingsService extends DomainService

  model: require './../models/settings'

  getByUserId: (userId, callback) =>
    @model.findOne({ userId: userId }).lean().exec (e, r) =>
      if ! r? then r = {}
      callback r


  create: (userId, o, callback) =>
    o.userId = userId.toString()
    new @model( o ).save (e, r) => callback r


  update: (userId, data, callback) =>
    ups = und.clone data
    delete ups._id
    @model.findOneAndUpdate({userId:userId}, ups).lean().exec (e, r) =>
      callback r