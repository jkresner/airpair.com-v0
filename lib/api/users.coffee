class UserApi

  model: require './../models/user'

  detail: (req, res) =>

    if req.isAuthenticated()
      user = und.clone req.user
      if user.google then delete user.google.token
      if user.twitter then delete user.twitter.token
      if user.bitbucket then delete user.bitbucket.token
      if user.github then delete user.github.token
      if user.stack then delete user.stack.token
    else
      user = authenticated : false

    res.send user


module.exports = new UserApi()