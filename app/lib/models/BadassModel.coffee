module.exports = class BadassModel extends Backbone.Model

  idAttribute:  '_id'     # mongo ids

  constructor: (args) ->
    Backbone.Model::constructor.apply @, arguments
    #@on 'error', @checkfor500, @

  validateNonEmptyArray: (value, attr, computedState) ->
    # console.log 'validateNonEmptyArray', value, attr, computedState
    if !value? || value.length is 0 then true

  # very useful for calculating extra values needed for templates
  extend: (args) ->
    _.extend @toJSON(), args

  #compare the value of an attribute to the supplied value ignoring case
  #ignoreCaseCompare: (attr, value) ->
  #  @get(attr).toLowerCase() == value.toLowerCase()

  # checkfor500: (model, errors, options) ->
  #   if errors? & errors.code is 500
  #     exports.render500 errors, 'Failed to get data: ' + model.url

  # toggle: (name, value) ->
  #   filters = @get(name)
  #   if !filters?
  #     @set name, [value]
  #   else
  #     # if it's not yet in the list, add it
  #     if _.indexOf(filters, value) == -1
  #       if value == 'all'
  #         @set name, ['all']
  #       else if @isDefault(name)
  #         @set name, [value]
  #       else
  #         # need to do this so our event listeners fire..
  #         @set name, (_.union filters, [value])

  #     # else let's remove it
  #     else
  #       without = _.without @get(name), value
  #       if without.length == 0 then without = ['all']
  #       @set name, without