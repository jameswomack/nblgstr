class NG.DevelopmentError extends Error

  constructor : (@message) ->
    @name = "DevelopmentError"


class NG.Sanity
  @check : (objectToTest, aType, aMessage, testAsBoolean) ->
    objectToTest = new Boolean objectToTest if testAsBoolean
    throw new TypeError aMessage unless objectToTest instanceof aType
