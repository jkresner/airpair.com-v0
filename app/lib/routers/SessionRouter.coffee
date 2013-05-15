BadassRouter = require './BadassRouter'

module.exports = class SessionRouter extends BadassRouter

  superConstructor: BadassRouter::constructor

  # can /should override with your own application specific model
  model: require './../models/SessionModel'


  # seems handy to know if the session is authenticated before we do
  # anything else
  loadSessionSync: on


  # takes pageData to pre-load data into the SPA without ajax calls
  constructor: (pageData, callback) ->

    @app = {} if !@app?
    @pageData = pageData if pageData?

    @_setSession pageData, callback


  # set our session model, can override this if useful, e.g. in testing
  # or maybe you want to use local storage instead of xhr ...
  _setSession: (pageData, callback) =>

    setSuccess = (model, resp, opts) =>

      if @logging
        $log 'SessionRouter.setSession', @app.session.attributes

      @superConstructor.call @, pageData, callback

    @app.session = new @model()
    @setOrFetch @app.session, pageData.session, { success: setSuccess }
