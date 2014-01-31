DomainService   = require './_svc'

module.exports = class ExpertsService extends DomainService

  model: require './../models/expert'

  # getByBookme: (urlSlug, callback) =>
  #   @model.findOne({ 'bookMe.urlSlug': urlSlug }).lean().exec (e, r) =>
  #     return callback e if e then
  #     return callback null, {} if !r.bookMe || !r.bookMe.enabled
  #     callback null, r
