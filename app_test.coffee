module.exports = (app) ->

  app.use require('./test/server/test-passport').initialize app