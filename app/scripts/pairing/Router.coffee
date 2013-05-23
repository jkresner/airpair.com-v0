S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairRouter

  pushStateRoot: '/pair-programmers'

  routes:
    ''                 : 'about'
    'about'            : 'about'
    'instructions'     : 'instructions'
    'post'             : 'post'
    'thanks'           : 'thanks'
    'share'            : 'share'

  appConstructor: (pageData, callback) ->
    d = {}
    v =
      aboutView: new V.AboutView()
      instructionsView: new V.InstructionsView()
      postView: new V.PostView()
      thanksView: new V.ThanksView()
      shareView: new V.ShareView()
    _.extend d, v

  initialize: (args) ->


  about: ->
    @app.aboutView.render()

  instructions: ->
    @app.instructionsView.render()

  post: ->
    @app.postView.render()

  thanks: ->
    @app.thanksView.render()

  share: ->
    @app.shareView.render()
