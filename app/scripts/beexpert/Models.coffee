BB = require './../../lib/BB'
Shared = require './../shared/Models'
exports = {}


exports.User = Shared.User
exports.Expert = Shared.Expert
exports.Company = class Company extends Shared.Company


module.exports = exports