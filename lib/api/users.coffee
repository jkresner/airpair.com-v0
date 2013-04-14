class UserApi

  model: require './../models/user'

  detail: (req, res) =>

    if req.isAuthenticated()
      user = req.user
    else
      user = authenticated : false

    res.send user


module.exports = new UserApi()