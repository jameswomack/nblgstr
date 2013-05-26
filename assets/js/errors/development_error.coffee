class Frei.DevelopmentError extends Error

  constructor : (@message) ->
    @name = "DevelopmentError"


class Frei.Sanity
  @check : (objectToTest, aType, aMessage, testAsBoolean) ->
    objectToTest = new Boolean objectToTest if testAsBoolean
    throw new TypeError aMessage unless objectToTest instanceof aType
