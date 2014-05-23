BB     = require 'BB'
Shared = require './../shared/Models'

exports = {}


class User extends Shared.User
  urlRoot: '/api/users'
  validation:
    email:           { required: true }


class Company extends BB.BadassModel
  urlRoot: '/api/companys'


class PayMethod extends BB.BadassModel
  urlRoot: '/api/paymethods'


module.exports = {PayMethod,User,Company}
