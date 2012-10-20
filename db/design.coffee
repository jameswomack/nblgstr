require './index'

module.exports = {
  _id: "_design/#{NG.config.db.view_id}"
  , views:
    type:
      map: (doc) ->
        emit doc.t, null if (doc.t)
    project_search:
      map: (d) ->
        emit d.name, d._id if d.t is 'project'
    parents:
      map: (d) ->
        for k, v of d
          [p,type] = k.split '_', 2
          if p == 'p'
            if v._id?
              emit [type, d._id], v
            else if v.length?
              emit [type,d._id], parent_obj for parent_obj in v
    children:
      map: (d) ->
        for k, v of d
          [p,_] = k.split '_', 2
          if p == 'p'
            if v._id?
              emit [d.t,v._id], id: d._id
            else if v.length?
              emit [d.t,parent_obj._id], id: d._id for parent_obj in v
  , lists: {}
  , shows: {}
}
