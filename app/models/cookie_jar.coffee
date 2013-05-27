class CookieJar
  @maxAge: 86400000
  @resCookie: (res, key, value) ->
    res.cookie key, value, { maxAge: @cookieMaxAge, httpOnly: false}

module.exports = CookieJar