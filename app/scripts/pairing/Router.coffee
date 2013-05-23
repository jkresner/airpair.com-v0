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
    d =
      meetup: new Backbone.Model
        spreadsheetKey: "0AsOwlciMAOtXdDVEdFRJMUlyZFRlUHgzYnozOGhnTUE"
        chatRoomName: "pairprogrammers"
        formKey: "dDVEdFRJMUlyZFRlUHgzYnozOGhnTUE6MQ"
        hashTag: "ilovepairprogramming"

    v =
      aboutView: new V.AboutView model: d.meetup
      instructionsView: new V.InstructionsView model: d.meetup
      postView: new V.PostView model: d.meetup
      thanksView: new V.ThanksView model: d.meetup
      shareView: new V.ShareView model: d.meetup

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
