BB = require './../../lib/BB'
Shared = require './../shared/Models'

exports = {}


exports.User = class User extends Shared.User
  urlRoot: '/api/users'


module.exports = exports
