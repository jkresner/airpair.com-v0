ViewDataService  = require '../services/_viewdata'
viewData         = new ViewDataService()


getByPropertyIndex = (obj, index) =>
  props = index.split '.'
  r = obj
  r = r[prop] for prop in props
  r


module.exports =


  file: (fileName) ->
    (req, resp, next) ->
      resp.sendfile "./public/#{fileName}.html"


  render: (fileName, params) ->
    params = [] if !params?

    (req, resp, next) ->
      args = [req.user]
      args.push getByPropertyIndex(req,idx) for idx in params
      args.push (e, data) =>
        if e then return next e
        data.authenticated = req.isAuthenticated()
        data.reqUrl = req.url
        resp.render "#{fileName}.html", data

      # convention we just rip out the path to get viewDataFunction
      fnName = fileName.replace('adm/', '').replace('payment/', '')

      if viewData[fnName]?
        viewData[fnName].apply viewData, args
      else
        resp.render "#{fileName}.html"
