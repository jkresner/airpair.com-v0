S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/pair-programmers'

  routes:
    ''        : 'about'
    'about'   : 'about'
    'signup'  : 'signup'
    'thanks'  : 'thanks'
    'share'   : 'share'

  appConstructor: (pageData, callback) ->
    d = {}
    v = {}

    _.extend d, v

  initialize: (args) ->