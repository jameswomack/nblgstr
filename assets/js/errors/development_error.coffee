class BB.DevelopmentError extends Error
  constructor : (@message) ->
    @name = "DevelopmentError"


class BB.Sanity
  @check : (objectToTest, aType) ->
    throw new TypeError "object #{objectToTest} is not of type #{aType}" unless objectToTest["is#{aType.capitalize()}"]
