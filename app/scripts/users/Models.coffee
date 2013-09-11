BB = require './../../lib/BB'
Shared = require './../shared/Models'

exports = {}


exports.User = class User extends Shared.User
  urlRoot: '/api/users'
  validation:
    email:           { required: true }


exports.Company = class Company extends BB.BadassModel
  urlRoot: '/api/companys'


module.exports = exports
