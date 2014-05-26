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

  render: (fileName, propList) ->
    propList = propList || []

    (req, resp, next) ->

      vdSvc = new ViewDataSvc req.user

      # convention we just rip out the path to get viewDataFunction
      fnName = fileName.replace('adm/', '').replace('payment/', '')

      if !vdSvc[fnName]?
        resp.render "#{fileName}.html"
      else
        args = []

        for prop in propList
          args.push getProp req, prop

        args.push (e, getViewData) =>
          if e
            if vdSvc.logging then $log 'viewData', fnName, 'e', e
            next e
          else
            data =
              isProd: cfg.isProd.toString()
              session: vdSvc.session false
              reqUrl: req.url
            data = _.extend data, getViewData()

            if vdSvc.logging then $log 'viewData', fnName, data

            resp.render "#{fileName}.html", data

        vdSvc[fnName].apply vdSvc, args

