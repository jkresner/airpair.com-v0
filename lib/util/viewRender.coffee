async = require 'async'
ViewDataSvc = require '../services/_viewdata'

prerender = (res, filename, callback) =>
  res.render "templates/#{filename}.jade", (err, rendered) =>
    if (err)
      throw err
    else
      callback(err, {name: filename, html: rendered})

getProp = (req, res, path, callback) =>
  if _.isPlainObject(path) && path.template?
    prerender(res, path.template, callback)
  else
    props = path.split '.'
    r = req
    for prop in props
      r = r[prop]
    callback(null, r)

renderView = (req, res, name, data={}) ->
  if req.method == "HEAD"
    res.end("")
  else
    console.log "Rendering", "#{name}.html"
    res.render "#{name}.html", data, (err, html) ->
      if err?
        res.render "#{fileName}.jade", data
      else
        res.end(html)

render = (fileName, propList=[]) ->
  (req, res, next) ->

    vdSvc = new ViewDataSvc req.user

    # convention we just rip out the path to get viewDataFunction
    fnName = fileName.replace('adm/', '').replace('payment/', '').replace('landing/', '')

    if !vdSvc[fnName]?
      renderView req, res, fileName, { segmentioKey: config.analytics.segmentio.writeKey }
    else
      async.map propList
      , (prop, callback) ->
        getProp(req, res, prop, callback)
      , (err, args) =>
        args.push (e, getViewData) =>
          if e
            if vdSvc.logging then $log 'viewData', fnName, 'e', e
            if e.status? && e.status == 404
              res.render('404.html', { status: 404, url: req.url })
            else
              next e
          else
            data =
              firebase: req.firebase
              isProd: config.isProd.toString()
              session: vdSvc.session false
              reqUrl: req.url
              segmentioKey: config.analytics.segmentio.writeKey
            data = _.extend data, getViewData()

            if vdSvc.logging then $log 'viewData', fnName, data

            renderView(req, res, fileName, data)

        vdSvc[fnName].apply vdSvc, args



module.exports =

  redirect: (app, origin, destination) ->
    app.get origin, (req, r) -> r.redirect req.url.replace(origin,destination)

  file: (fileName) ->
    (req, res, next) ->
      res.sendfile "./public/#{fileName}.html"

  renderTemplate: (req, res) ->
    res.render "templates/#{req.params.scope}/#{req.params.template}.jade", (err, html) ->
      if err? && /Failed to lookup view/.test(err.message)
        res.render('404.html', { status: 404, url: req.url })
      else
        res.send(html)

  render: render

  renderHome: (req, r, n) ->
    if req.isAuthenticated() then n()
    else render('home')(req, r, n)

