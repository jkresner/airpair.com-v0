BB = require './../../lib/BB'
Shared = require './../shared/Models'

exports = {}


class SharedCards extends Shared.Settings
  url: -> '/api/shared-cards/settings'


class User extends Shared.User
  urlRoot: '/api/users'
  validation:
    email:           { required: true }


class Company extends BB.BadassModel
  urlRoot: '/api/companys'


module.exports = {SharedCards,User,Company}
