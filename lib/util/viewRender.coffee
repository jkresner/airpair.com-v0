viewData = new (require '../services/_viewdata')()

# getProp(process, 'env.USER')
# yields 'dtrejo'
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
    propList = [] if !propList?
    (req, resp, next) ->
      $log 'render', fileName, propList, req
      args = [ req.user ]
      for prop in propList
        args.push getProp(req, prop)
      args.push (e, data) =>
        if e then return next e
        data.authenticated = req.isAuthenticated()
        data.reqUrl = req.url
        resp.render "#{fileName}.html", data

      # convention we just rip out the path to get viewDataFunction
      fnName = fileName.replace('adm/', '').replace('payment/', '')

      if viewData[fnName]?
        return viewData[fnName].apply viewData, args

      $log 'render', "#{fileName}.html"
      resp.render "#{fileName}.html"
