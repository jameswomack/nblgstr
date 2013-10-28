// Generated by CoffeeScript 1.6.3
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

BB.Model = (function(_super) {
  __extends(Model, _super);

  Model.persist(BB.CouchStorage);

  Model.primaryKey = "_id";

  Model.encode("_rev", '_attachments', 'created', 'modified');

  Model.encode('created', {
    decode: function(value, key, incomingJSON, outgoingObject, record) {
      var _value;
      _value = new Date(value);
      return _value.format();
    }
  });

  Model.encode('modified', {
    decode: function(value, key, incomingJSON, outgoingObject, record) {
      var _value;
      _value = new Date(value);
      return _value.format();
    }
  });

  Model.classAccessor('resourceName', function() {
    return this.name;
  });

  Model.prototype.valid = function() {
    var k, keys, _i, _len, _ref;
    keys = Array.prototype.slice.call(arguments);
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
      k = keys[_i];
      if (!((_ref = this.get(k)) != null ? _ref.length : void 0) || this.get(k) === 'Invalid Date') {
        return false;
      }
    }
    return true;
  };

  function Model() {
    Model.__super__.constructor.apply(this, arguments);
    if (this.constructor.__attachment_styles) {
      this.set('_attachment_styles', this.constructor.__attachment_styles);
    }
  }

  Model.include_attachments = function() {
    var _refer;
    return this.encode('_attachments', _refer = this, {
      decode: function(value, key, incomingJSON, outgoingObject, record) {
        var a, k, v, _ref;
        a = {
          attr: {}
        };
        _ref = incomingJSON._attachments;
        for (k in _ref) {
          v = _ref[k];
          if (k.indexOf('gen/' === 0)) {
            (function(k, v) {
              var attr, name, style, _base, _ref1;
              _ref1 = k.split('/'), attr = _ref1[0], name = _ref1[1], style = _ref1[2];
              style = style.replace(/\..*/, '');
              if ((_base = a.attr)[name] == null) {
                _base[name] = {};
              }
              a.attr[name][style] = v;
              a.attr[name][style].filename = k;
              return _refer.accessor(name, {
                get: function() {
                  var pic, _ref2;
                  pic = (_ref2 = this.get('_attachments').attr[name]) != null ? _ref2.original : void 0;
                  if (pic && pic.filename) {
                    return "/att/" + (this.get('id')) + "/" + pic.filename + "." + pic.digest + "." + (MimeTypes.ext(pic.content_type));
                  }
                  return this["_" + name];
                }
              });
            })(k, v);
          }
        }
        return a;
      }
    });
  };

  Model.attachment = function(attr_name, styles) {
    var a,
      _this = this;
    this.encode('_attachment_styles');
    a = this.__attachment_styles != null ? this.__attachment_styles : this.__attachment_styles = {};
    a[attr_name] = styles;
    this.accessor(attr_name, {
      get: function() {
        var id, namedAttachmentObject, originalAttachment, pic, _attachments;
        _attachments = this.get('_attachments');
        namedAttachmentObject = _attachments.attr[attr_name];
        originalAttachment = namedAttachmentObject.original;
        if (pic = originalAttachment) {
          if (pic.filename) {
            id = this.get('id');
            console.log(id, this.get('_id'));
            return "/img/" + id + "/" + pic.filename + "." + pic.digest + "." + (MimeTypes.ext(pic.content_type));
          } else {
            return this["_" + attr_name];
          }
        }
      },
      set: function(k, v) {
        var _ref;
        a = (_ref = this.get('_attachments')) != null ? _ref : this.set('_attachments', {
          attr: {}
        });
        a.attr[k] = {
          original: v
        };
        return this["_" + attr_name] = "data:" + v.content_type + ";base64," + v.data;
      }
    });
    Object.extended(styles).keys().each(function(style) {
      return (function(style) {
        return _this.accessor("" + attr_name + "_" + style, {
          get: function() {
            var pic, _ref, _ref1, _ref2;
            if (pic = (_ref = this.get('_attachments')) != null ? (_ref1 = _ref.attr) != null ? (_ref2 = _ref1[attr_name]) != null ? _ref2[style] : void 0 : void 0 : void 0) {
              return "/img/" + (this.get('id')) + "/" + pic.filename + "." + pic.digest + "." + (MimeTypes.ext(pic.content_type));
            }
          }
        });
      })(style);
    });
    return this.encode('_attachments', {
      decode: function(value, key, incomingJSON, outgoingObject, record) {
        var attr, k, name, style, v, _base, _ref, _ref1;
        a = {
          attr: {}
        };
        _ref = incomingJSON._attachments;
        for (k in _ref) {
          v = _ref[k];
          if (!(k.indexOf('attr/' === 0))) {
            continue;
          }
          _ref1 = k.split('/'), attr = _ref1[0], name = _ref1[1], style = _ref1[2];
          style = style.replace(/\..*/, '');
          if ((_base = a.attr)[name] == null) {
            _base[name] = {};
          }
          a.attr[name][style] = v;
          a.attr[name][style].filename = k;
        }
        return a;
      },
      encode: function(value, key, builtJSON, record) {
        var k, kk, v, vv, _ref;
        a = {};
        _ref = value.attr;
        for (k in _ref) {
          v = _ref[k];
          for (kk in v) {
            vv = v[kk];
            a["attr/" + k + "/" + kk] = vv;
          }
        }
        return a;
      }
    });
  };

  Model.allKeys = function() {
    var _all;
    _all = Object.keys(this.prototype._batman.encoders._storage).map(function(k) {
      return k.substring(1);
    });
    return _all.exclude.apply(_all, Object.keys(BB.Model.prototype._batman.encoders._storage));
  };

  Model.all = function() {
    var args, cb, set, _i,
      _this = this;
    args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), cb = arguments[_i++];
    set = new Batman.Set;
    this.load.apply(this, __slice.call(args).concat([function(err, res) {
      if (!err) {
        set.add.apply(set, res);
      }
      if (cb != null) {
        return cb(err, set);
      }
    }]));
    return set;
  };

  Model.childOf = function(relation) {
    var field_name, objectType, parent, resourceName, singular, singularResourceName;
    parent = Batman.helpers.underscore(relation);
    objectType = Batman.helpers.singularize(parent);
    resourceName = this.prototype.constructor.get('resourceName').toLowerCase();
    singularResourceName = Batman.helpers.singularize(resourceName);
    singular = parent === objectType;
    field_name = "p_" + objectType;
    if (!singular) {
      this.encode(relation, {
        encode: function(v, k, obj, r) {
          obj[field_name] = v.toArray().map(function(p) {
            if (p._id != null) {
              return p;
            } else {
              return {
                _id: p.get('id')
              };
            }
          });
          r.fromJSON(obj);
        }
      });
    }
    this.encode(field_name, {
      encode: function(v, k, jsonObj, r) {
        if (singular) {
          return v;
        }
      }
    });
    return this.accessor(relation, {
      set: function(k, v) {
        var parent_data;
        if ((v != null ? typeof v.get === "function" ? v.get(resourceName) : void 0 : void 0) == null) {
          resourceName = Batman.helpers.pluralize(resourceName);
        }
        if (singular) {
          if (Batman.typeOf(v) === 'Set') {
            throw new BB.DevelopmentError("Singular relations require a Batman.Object, Batman.Set given.");
          } else if ((typeof v.get === "function" ? v.get(singularResourceName) : void 0) && (typeof v.get === "function" ? v.get(singularResourceName).length : void 0) > 0) {
            throw new BB.DevelopmentError("Parent model should not have more than 1 children associated.");
          }
          parent_data = Batman.typeOf(v) === 'String' ? {
            _id: v
          } : {
            _id: v.get('id')
          };
        } else {
          parent_data = v;
        }
        if (typeof v.get === "function" ? v.get(resourceName) : void 0) {
          v.get(resourceName).add(this);
        }
        return this.set(field_name, parent_data);
      },
      get: function(k) {
        var parentObj;
        parentObj = BB[Batman.helpers.classify(objectType)];
        if (singular) {
          if (this.get(field_name) == null) {
            return null;
          }
          return parentObj.find(this.get(field_name)._id, function(err, result) {
            return result;
          });
        } else {
          return parentObj.all({
            view: 'parents',
            key: [objectType, this.get('id')]
          }, function(err, results) {
            return results;
          });
        }
      },
      unset: function() {
        return this.unset(field_name);
      }
    });
  };

  Model.parentOf = function(relation) {
    var field_name, objectType, resourceName, singular;
    objectType = Batman.helpers.singularize(relation);
    resourceName = this.prototype.constructor.get('resourceName').toLowerCase();
    singular = objectType === relation;
    field_name = "p_" + objectType;
    if (!singular) {
      this.prototype.on('save', function() {
        var _this = this;
        return this.get(relation).forEach(function(r) {
          if (r.get(resourceName) === void 0) {
            r.get(Batman.helpers.pluralize(resourceName)).add({
              _id: _this.get('id')
            });
          } else {
            r.set(resourceName, _this);
          }
          return r.save();
        });
      });
    }
    return this.accessor(relation, {
      set: function(k, v) {
        var related;
        if (!this.get('id')) {
          throw new BB.DevelopmentError("need to save first");
        }
        if (singular) {
          related = this.get(relation);
          return related.on('change', function(r) {
            if (r && r.length > 0) {
              throw new BB.DevelopmentError("Model should not have more than 1 children associated.");
            }
            v.set(resourceName, this);
            return v.save();
          });
        }
      },
      get: function() {
        if (!this.get('id')) {
          throw new BB.DevelopmentError("need to save first");
        }
        return BB[Batman.helpers.classify(objectType)].all({
          view: 'children',
          key: [objectType, this.get('id')]
        }, function(err, results) {
          return results;
        });
      },
      unset: function() {
        return this.unset(field_name);
      }
    });
  };

  return Model;

})(Batman.Model);