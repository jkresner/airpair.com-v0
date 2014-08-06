ViewDataSvc = require '../services/_viewdata'

getProp = (obj, path) =>
  props = path.split '.'
  r = obj
  for prop in props
    r = r[prop]
  r

module.exports =

  file: (fileName) ->
    (req, resp, next) ->
      resp.sendfile "./public/#{fileName}.html"

  render: (fileName, propList=[]) ->
    (req, resp, next) ->

      renderTemplate = (name, data={}) ->
        resp.render "#{name}.html", data, (err, html) ->
          if err?
            resp.render "#{fileName}.jade", data
          else
            resp.end(html)


      vdSvc = new ViewDataSvc req.user

      # convention we just rip out the path to get viewDataFunction
      fnName = fileName.replace('adm/', '').replace('payment/', '').replace('landing/', '')

      if !vdSvc[fnName]?
        renderTemplate fileName, { segmentioKey: config.analytics.segmentio.writeKey }
      else
        args = _.map propList, (prop) ->
          getProp req, prop

        args.push (e, getViewData) =>
          if e
            if vdSvc.logging then $log 'viewData', fnName, 'e', e
            if e.status? && e.status == 404
              resp.render('404.html', { status: 404, url: req.url })
            else
              next e
          else
            data =
              isProd: config.isProd.toString()
              session: vdSvc.session false
              reqUrl: req.url
              segmentioKey: config.analytics.segmentio.writeKey
            data = _.extend data, getViewData()

            if vdSvc.logging then $log 'viewData', fnName, data

            renderTemplate fileName, data

        vdSvc[fnName].apply vdSvc, args
