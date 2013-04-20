exports = {}
models = require './Models'

class exports.SessionPage

  constructor: (pageData, callback) ->
    @session = new models.User()
    @session.fetch success: (model, options, resp) =>
      #$log '@session', @session.attributes
      @initialize pageData
      callback @

  setOrFectch: (model, local) ->
    if local? then model.set local else model.fetch reset:true

  resetOrFectch: (collection, local) ->
    if local? then collection.reset local else collection.fetch reset:true


module.exports = exports