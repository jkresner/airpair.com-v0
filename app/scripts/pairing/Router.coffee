S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairRouter

  pushStateRoot: '/pair-programmers'

  routes:
    ''                 : 'about'
    'about'            : 'about'
    'post'             : 'post'
    'thanks'           : 'thanks'
    'share'            : 'share'
    'instructions'     : 'instructions'

  appConstructor: (pageData, callback) ->
    d = {}
    v = {}

    _.extend d, v

  initialize: (args) ->