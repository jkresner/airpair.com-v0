module.exports = (app, render) ->

  app.get '/so10/:id', render 'landing/so10', ['params.id']
  app.get '/so11/:id', render 'landing/so11', ['params.id']
  app.get '/so12/:id', render 'landing/so12', ['params.id']
  app.get '/welcome-back', render 'landing/welcome-back', ['params.id']
  app.get '/so13/:id', render 'landing/so13', ['params.id']
  app.get '/so14/:id', render 'landing/so14', ['params.id']
  app.get '/so15/:id', render 'landing/so15', ['params.id']
  app.get '/so16/:id', render 'landing/so16', ['params.id']
  app.get '/so17/:id', render 'landing/so17', ['params.id']

  app.get '/speakers', render 'landing/speakers'
  app.get '/airconf2014', render 'landing/speakers'

  app.get '/railsconf2014', render 'landing/railsconf'
  app.get '/rails/consulting', render 'landing/railsconsulting'
  app.get '/googleio-specials', render 'landing/googleio'
