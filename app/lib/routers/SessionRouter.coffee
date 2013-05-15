BadassRouter = require './BadassRouter'

module.exports = class SessionRouter extends BadassRouter

  # can /should override with your own application specific model
  model: require './../models/SessionModel'

  # seems handy to know if the session is authenticated before we do
  # anything else
  loadSessionSync: on

  # takes pageData to pre-load data into the SPA without ajax calls
  constructor: (pageData, callback) ->

    @app = {} if !@app?
    @pageData = pageData if pageData?

    setSessionSuccess = (model, resp, opts) =>

      if @logging
        $log 'SessionRouter.setSession', @app.session.attributes

      BadassRouter::constructor.call @, pageData, callback

    @app.session = new @model()
    @setOrFetch @app.session, pageData.session, { success: setSessionSuccess }