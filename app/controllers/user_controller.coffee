class UserController
  @idFromReq: (req) ->
    req.session.passport.user

module.exports = UserController