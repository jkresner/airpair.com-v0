exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
## Content Views
#############################################################################

class exports.AboutView extends BB.BadassView
  el: '#about'
  tmpl: require './templates/about'
  render: -> @$el.html @tmpl @model.toJSON()

class exports.InstructionsView extends BB.BadassView
  el: '#instructions'
  tmpl: require './templates/instructions'
  render: -> @$el.html @tmpl @model.toJSON()

class exports.PostView extends BB.BadassView
  el: '#post'
  tmpl: require './templates/post'
  render: -> @$el.html @tmpl @model.toJSON()

class exports.ThanksView extends BB.BadassView
  el: '#thanks'
  tmpl: require './templates/thanks'
  render: -> @$el.html @tmpl @model.toJSON()

class exports.ShareView extends BB.BadassView
  el: '#share'
  tmpl: require './templates/share'
  render: -> @$el.html @tmpl @model.toJSON()

#############################################################################
##
#############################################################################

module.exports = exports