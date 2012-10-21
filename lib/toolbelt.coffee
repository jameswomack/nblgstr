class Toolbelt
  @define : (Class,k,v,isEnumerable) ->
    Object.defineProperty(Class::, k, {value: v, enumerable: isEnumerable}) unless Class::[k]

  @defineAccessor : (Class,k,o,isEnumerable) ->
    o.enumerable ?= !!(isEnumerable)
    Object.defineProperty(Class::, k, o) unless Class::[k]

  @extendPrototypeSafely : (Class,someExtensions) ->
    for k,v of someExtensions
      do (k,v) ->
        @define Class, k, v

  @extend : (Class) ->
    @extendPrototypeSafely Class, @
    for k,v of Class
      Class[k].bind(Class) if @[k] and typeof @[k] is 'function'
    Class

module.exports = Toolbelt if !window?