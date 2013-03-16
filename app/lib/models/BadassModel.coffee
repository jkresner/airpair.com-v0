module.exports = class BadassModel extends Backbone.Model

  idAttribute:  '_id'     # mongo ids

  constructor: (args) ->
    Backbone.Model::constructor.apply @, arguments
    #@on 'error', @checkfor500, @

  #compare the value of an attribute to the supplied value ignoring case
  #ignoreCaseCompare: (attr, value) ->
  #  @get(attr).toLowerCase() == value.toLowerCase()

  # checkfor500: (model, errors, options) ->
  #   if errors? & errors.code is 500
  #     exports.render500 errors, 'Failed to get data: ' + model.url
