module.exports = class Authority
  if process?
    env = process.env
    if env.COUCH_USERNAME and env.COUCH_PASSWORD
      @u = env.COUCH_USERNAME
      @p = env.COUCH_PASSWORD
      @h =
        'Authorization': 'Basic ' + new Buffer(@u + ':' + @p).toString('base64')

  @assign: (o) ->
    o.username = @u
    o.password = @p
    "#{@u}:#{@p}@"
