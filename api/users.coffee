CRUDApi = require './_crud'

class UserApi extends CRUDApi

  model: require './../models/user'

  detail: (req, res) =>
    console.log 'user/detail', req.user
    res.send req.user


module.exports = new UserApi()