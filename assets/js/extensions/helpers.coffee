Batman.mixin Batman.helpers,
  classify: (string) ->
    titlelized = Batman.helpers.capitalize(string).replace( /_/, '' )
    Batman.helpers.singularize titlelized
  urlParams: (w) ->
    ps = w.location.hash.split('?')[1].split('&')
    vals = {}
    [a = ps[k].split('='), vals[a[0]] = a[1]] for k of ps
    vals
