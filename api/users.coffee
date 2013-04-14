CRUDApi = require './_crud'

class UserApi extends CRUDApi

  model: require './../models/user'

  detail: (req, res) =>

    user = if req.isAuthenticated() then req.user else { authenticated: false }
    console.log 'user/detail', user
    res.send user


module.exports = new UserApi()