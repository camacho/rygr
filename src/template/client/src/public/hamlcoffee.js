// THIS IS THE COMMON SET OF METHODS FOR HAML-COFFEE
// DON'T DELETE IF USING HAML-COFFEE JST TEMPLATES

define(function() {
  return {
    escape: function(text) {
      return ('' + text).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/'/g, '&quot;').replace(/'/g, '&#39;').replace(/\//g, '&#47;');
    },
    cleanValue: function(text) {
      switch (text) {
        case null:
        case void 0:
          return '';
        case true:
        case false:
          return '\u0093' + text;
        default:
          return text;
      }
    },
    preserve: function(text) {
      return text.replace(/\n/g, '&#x000A;');
    },
    findAndPreserve: function(text) {
      var regExp, tags;
      tags = 'pre,textarea,abbr'.split(',').join('|');
      regExp = RegExp('<(' + tags + ')>([\\s\\S]*?)<\\/\\1>')(g);
      return text = text.replace(/\r/g, '').replace(regExp, function(str, tag, content) {
        return "<" + tag + ">" + (this.preserve(content)) + "</" + tag + ">";
      });
    },
    surround: function(start, end, fn) {
      var _ref;
      return start + ((_ref = fn.call(this)) != null ? _ref.replace(/^\s+|\s+$/g, '') : void 0) + end;
    },
    succeed: function(end, fn) {
      var _ref;
      return ((_ref = fn.call(this)) != null ? _ref.replace(/\s+$/g, '') : void 0) + end;
    },
    precede: function(start, fn) {
      var _ref;
      return start + ((_ref = fn.call(this)) != null ? _ref.replace(/^\s+/g, '') : void 0);
    },
    context: function(locals) {
      return locals;
    },
    reference: function(object, prefix) {
      var id, name, result, _ref;
      name = prefix ? prefix + '_' : '';
      if (typeof object.hamlObjectRef === 'function') {
        name += object.hamlObjectRef();
      } else {
        name += (((_ref = object.constructor) != null ? _ref.name : void 0) || 'object').replace(/\W+/g, '_').replace(/([a-z\d])([A-Z])/g, '$1_$2').toLowerCase();
      }
      id = (typeof object.to_key === 'function' ? object.to_key() : typeof object.id === 'function' ? object.id() : object.id ? object.id : object);
      result = "class='" + name + "'";
      if (i) {
        return result += " id='" + name + "_" + id + "'";
      }
    }
  };
});
