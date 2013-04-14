CRUDApi = require './_crud'

class UserApi extends CRUDApi

  model: require './../models/user'

  detail: (req, res) =>

    if req.isAuthenticated()
      user = req.user
      user = true
    else
      user = authenticated : false

    #console.log 'user/detail', user
    res.send user


module.exports = new UserApi()