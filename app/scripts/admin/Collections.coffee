exports = {}
BB = require './../../lib/BB'
Models = require './Models'


class exports.Leads extends BB.FilteringCollection
  model: Models.Lead
  url: '/api/leads'



module.exports = exports