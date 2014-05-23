require.register("BB", function(exports, require, module) {

  module.exports = {
    BadassModel: require('BadassModel'),
    SublistModel: require('SublistModel'),
    SessionModel: require('SessionModel'),
    FilteringCollection: require('FilteringCollection'),
    PagingCollection: require('PagingCollection'),
    BadassView: require('BadassView'),
    HasErrorStateView: require('HasErrorStateView'),
    HasBootstrapErrorStateView: require('HasBootstrapErrorStateView'),
    ModelSaveView: require('ModelSaveView'),
    EnhancedFormView: require('EnhancedFormView'),
    BadassAppRouter: require('BadassAppRouter'),
    SessionRouter: require('SessionRouter')
  };

});

;require.register("FilteringCollection", function(exports, require, module) {
" FilteringCollection\n(1) Holds an original AND a filtered view of it's models\n(2) Can sort filtered models on any arbitrary attribute\n    - sort can be invoked multiple times with different attributes to get\n     sorted by A then B ";
var FilteringCollection, reverseString,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

FilteringCollection = (function(_super) {
  __extends(FilteringCollection, _super);

  function FilteringCollection() {
    this.on('reset', this.resetFilteredModels, this);
    Backbone.Collection.prototype.constructor.apply(this, arguments);
  }

  FilteringCollection.prototype.resetFilteredModels = function() {
    return this.filteredModels = this.models;
  };

  FilteringCollection.prototype.sortFilteredModels = function(attr, direction, type) {
    this.filteredModels = this._sort(attr, direction, type);
    return this.trigger('sort');
  };

  FilteringCollection.prototype._sort = function(attr, direction, type) {
    if (attr == null) {
      return this.filteredModels;
    }
    if (direction === 'up' || (direction == null)) {
      this.comparator = function(m) {
        return m.get(attr);
      };
    } else if (type === 'String') {
      this.comparator = function(m) {
        return reverseString(m, attr);
      };
    } else {
      this.comparator = function(m) {
        return -1 * m.get(attr);
      };
    }
    return _.sortBy(this.filteredModels, this.comparator);
  };

  FilteringCollection.prototype.filterFilteredModels = function(f) {
    this.filteredModels = this._filter(f);
    if ((f != null) && (f.sort != null)) {
      this.filteredModels = this._sort(f.sort.attr, f.sort.direction, f.sort.type);
    }
    return this.trigger('filter');
  };

  FilteringCollection.prototype._filter = function(f) {
    console.log('override _filter in child class');
    return this.models;
  };

  return FilteringCollection;

})(Backbone.Collection);

reverseString = function(m, attr) {
  if (m.get(attr) == null) {
    return '';
  }
  return String.fromCharCode.apply(String, _.map(m.get(attr).split(""), function(c) {
    return 0xffff - c.charCodeAt();
  }));
};

module.exports = FilteringCollection;

});

;require.register("PagingCollection", function(exports, require, module) {
var FilteringCollection, PagingCollection,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

FilteringCollection = require('FilteringCollection');

" PagingAndFilterCollection\n(1) Can keep track of current page & return it using fetchpage() ";

PagingCollection = (function(_super) {
  __extends(PagingCollection, _super);

  PagingCollection.prototype.pageSize = 25;

  function PagingCollection(args) {
    FilteringCollection.prototype.constructor.apply(this, arguments);
    this.on('filter sort', this.resetPaging, this);
  }

  PagingCollection.prototype.resetFilteredModels = function() {
    FilteringCollection.prototype.resetFilteredModels.apply(this, arguments);
    return this.resetPaging();
  };

  PagingCollection.prototype.resetPaging = function() {
    this.totalPages = Math.ceil(this.filteredModels.length / this.pageSize);
    return this.currentPage = this.totalPages > 0 ? 1 : 0;
  };

  PagingCollection.prototype.setPage = function(page) {
    if (page === '»' && this.currentPage < this.totalPages) {
      return this.setPage(this.currentPage + 1);
    } else if (page === '«' && this.currentPage > 1) {
      return this.setPage(this.currentPage - 1);
    } else {
      page = parseInt(page);
      if (page <= this.totalPages && page > 0) {
        this.currentPage = page;
        return this.trigger('page');
      }
    }
  };

  PagingCollection.prototype.fetchPage = function() {
    var start;
    start = this.pageSize * (this.currentPage - 1);
    return _.first(_.rest(this.filteredModels, start), this.pageSize);
  };

  return PagingCollection;

})(FilteringCollection);

module.exports = PagingCollection;

});

;require.register("lib/collections/comparators", function(exports, require, module) {
var exports;

exports = {
  reversestring: function(m, attr) {
    if (m.get(attr) == null) {
      return '';
    }
    return String.fromCharCode.apply(String, _.map(m.get(attr).split(""), function(c) {
      return 0xffff - c.charCodeAt();
    }));
  }
};

});

;require.register("BadassModel", function(exports, require, module) {
" BadassModel add 2 basic bits of functionality to a normal Backbone.Model\n1) Auto-logging of events to\n2) Short hand to extend the json object of the model";
var BadassModel,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = BadassModel = (function(_super) {
  __extends(BadassModel, _super);

  BadassModel.prototype.logging = false;

  BadassModel.prototype.idAttribute = '_id';

  function BadassModel(args) {
    if (this.logging) {
      $log('BadassMode.ctor', args);
      this.enableLogging();
    }
    Backbone.Model.prototype.constructor.apply(this, arguments);
  }

  BadassModel.prototype.extendJSON = function(args) {
    return _.extend(this.toJSON(), args);
  };

  BadassModel.prototype.extend = function(args) {
    return this.extendJSON(args);
  };

  BadassModel.prototype.silentReset = function(args) {
    this.clear({
      silent: true
    });
    return this.set(args, {
      silent: true
    });
  };

  BadassModel.prototype.enableLogging = function() {
    var _this = this;
    this.modelTypeName = this.constructor.name;
    this.listenTo(this, 'change', function(e) {
      return $log("" + _this.modelTypeName + ".change", e);
    });
    this.listenTo(this, 'request', function(e) {
      return $log("" + _this.modelTypeName + ".request", e);
    });
    this.listenTo(this, 'invalid', function(e) {
      return $log("" + _this.modelTypeName + ".invalid", e);
    });
    return this.listenTo(this, 'error', function(e) {
      return $log("" + _this.modelTypeName + ".error", e);
    });
  };

  BadassModel.prototype.validateNonEmptyArray = function(value, attr, computedState) {
    if ((value == null) || value.length === 0) {
      return true;
    }
  };

  return BadassModel;

})(Backbone.Model);

});

// ;require.register("ErrorHandlingModel", function(exports, require, module) {


// });

;require.register("SessionModel", function(exports, require, module) {
var BadassModel, SessionModel, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BadassModel = require('BadassModel');

module.exports = SessionModel = (function(_super) {
  __extends(SessionModel, _super);

  function SessionModel() {
    _ref = SessionModel.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  SessionModel.prototype.urlRoot = '/api/session';

  return SessionModel;

})(BadassModel);

});

;require.register("SublistModel", function(exports, require, module) {
var BadassModel, SublistModel, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BadassModel = require('BadassModel');

"A model that has one or more of it's attributes that is as list\nwhere we can toggle a value in and out of that list";

module.exports = SublistModel = (function(_super) {
  __extends(SublistModel, _super);

  function SublistModel() {
    _ref = SublistModel.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  SublistModel.prototype.toggleAttrSublistElement = function(attr, value, compareDelegate) {
    var list, match;
    list = this.get(attr);
    if (list == null) {
      this.set(attr, [value]);
    } else {
      match = _.find(list, compareDelegate);
      if (match != null) {
        this.set(attr, _.without(list, match));
      } else {
        this.set(attr, _.union(list, [value]));
      }
    }
    return this.trigger("change:" + attr);
  };

  return SublistModel;

})(BadassModel);

});

;require.register("BadassAppRouter", function(exports, require, module) {
"BadassAppRouter takes the philosophical position that only one router\ncan be used for one html page / single page app and it is the top most\napp container object other than window.\n\nA bad ass router knows how to construct all the pieces of a page using\n@appConstructor. This includes all models, collections and views.\n\nIt also assumes that each route has an associated top level views\nwhich becomes visible when you hit that route and all other become hidden";
var BadassAppRouter,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = BadassAppRouter = (function(_super) {
  __extends(BadassAppRouter, _super);

  BadassAppRouter.prototype.logging = false;

  BadassAppRouter.prototype.pushState = true;

  BadassAppRouter.prototype.pushStateRoot = '/';

  BadassAppRouter.prototype.enableExternalProviders = true;

  function BadassAppRouter(pageData, callback) {
    var app, history,
      _this = this;
    if (this.logging) {
      history = "pushState: " + this.pushState + ", root: " + this.pushStateRoot;
      $log('BadassRouter.ctor', history, this.pageData, callback);
    }
    if (pageData != null) {
      this.pageData = pageData;
    }
    this.defaultFragment = this.getDefaultFragment();
    if (this.preConstructorHook != null) {
      this.preConstructorHook();
    }
    app = this.appConstructor(pageData, callback);
    this.app = this.app != null ? _.extend(this.app, app) : app;
    if (callback != null) {
      callback();
    }
    if (this.logging) {
      $log('BadassRouter.app', this.app);
    }
    this.initialize = _.wrap(this.initialize, function(fn, args) {
      var currentFragment;
      Backbone.history.start({
        pushState: _this.pushState,
        root: _this.pushStateRoot
      });
      if (_this.pushState) {
        _this.enablePushStateNavigate();
      }
      if (_this.logging) {
        $log("Router.init", args, _this.app);
      }
      fn.call(_this, args);
      if (_this.defaultFragment !== (currentFragment = Backbone.history.getFragment())) {
        _this.navTo(_this.defaultFragment);
      }
      if (_this.enableExternalProviders) {
        return _this.loadExternalProviders();
      }
    });
    this.wrapRoutes();
    Backbone.Router.prototype.constructor.apply(this, arguments);
  }

  BadassAppRouter.prototype.getDefaultFragment = function() {
    var fragment, root;
    if (this.pushState) {
      fragment = window.location.pathname;
      root = this.pushStateRoot.replace(/\/$/, '');
      if (!fragment.indexOf(this.pushStateRoot)) {
        fragment = fragment.substr(root.length);
      }
    } else {
      fragment = Backbone.history.getHash();
    }
    if (fragment === '/') {
      fragment = '';
    }
    return fragment;
  };

  BadassAppRouter.prototype.appConstructor = function(pageData, callback) {
    throw new Error('override appConstructor in child router & build all models, collections & views then return single objects');
  };

  BadassAppRouter.prototype.wrapRoutes = function() {
    var route, routeName, _results,
      _this = this;
    _results = [];
    for (route in this.routes) {
      routeName = route.replace(/:id/g, '').split('/')[0];
      if (routeName !== '') {
        if (this[routeName] == null) {
          this[routeName] = (function() {});
        }
        this[routeName].routeName = routeName;
        _results.push(this[routeName] = _.wrap(this[routeName], function(fn, args) {
          if (_this.logging) {
            $log("Router." + fn.routeName);
          }
          $(".route").hide();
          $("#" + fn.routeName).show();
          window.scrollTo(0, 0);
          _this.routeMiddleware(fn);
          return fn.call(_this, args);
        }));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  BadassAppRouter.prototype.routeMiddleware = function(routeFn) {};

  BadassAppRouter.prototype.loadExternalProviders = function() {};

  BadassAppRouter.prototype.navTo = function(routeUrl, trigger) {
    var currentFragment;
    if (trigger == null) {
      trigger = true;
    }
    currentFragment = Backbone.history.getFragment();
    if (currentFragment === routeUrl && trigger) {
      this.navigate('/#temp');
    }
    return this.navigate(routeUrl, {
      trigger: trigger
    });
  };

  BadassAppRouter.prototype.enablePushStateNavigate = function() {
    var _this = this;
    return $("body").on("click", "a", function(e) {
      var $a, href;
      $a = $(e.currentTarget);
      href = $a.attr('href');
      if (href.length && href.charAt(0) === '#') {
        e.preventDefault();
        return _this.navTo(href.replace('#', ''));
      }
    });
  };

  BadassAppRouter.prototype.setOrFetch = function(model, data, opts) {
    if (data != null) {
      model.set(data);
      if ((opts != null) && (opts.success != null)) {
        opts.success(model, 'set', opts);
      }
      return model.trigger('sync');
    } else {
      if (opts == null) {
        opts = {};
      }
      opts.reset = true;
      return model.fetch(opts);
    }
  };

  BadassAppRouter.prototype.resetOrFetch = function(collection, data, opts) {
    if (data != null) {
      collection.reset(data);
      if ((opts != null) && (opts.success != null)) {
        opts.success(collection, 'reset', opts);
      }
      return collection.trigger('sync');
    } else {
      if (opts == null) {
        opts = {};
      }
      opts.reset = true;
      return collection.fetch(opts);
    }
  };

  return BadassAppRouter;

})(Backbone.Router);

});

;require.register("SessionRouter", function(exports, require, module) {
var BadassAppRouter, SessionRouter,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BadassAppRouter = require('BadassAppRouter');

module.exports = SessionRouter = (function(_super) {
  __extends(SessionRouter, _super);

  SessionRouter.prototype.model = require('SessionModel');

  SessionRouter.prototype.loadSessionSync = true;

  function SessionRouter(pageData, callback) {
    this.setSession = __bind(this.setSession, this);
    var setSessionSuccess,
      _this = this;
    if (this.app == null) {
      this.app = {};
    }
    if (pageData != null) {
      this.pageData = pageData;
    }
    setSessionSuccess = function(model, resp, opts) {
      if (_this.logging) {
        $log('SessionRouter.setSession', _this.app.session.attributes);
      }
      return BadassAppRouter.prototype.constructor.call(_this, pageData, callback);
    };
    this.app.session = new this.model();
    this.setSession(pageData.session, setSessionSuccess);
  }

  SessionRouter.prototype.setSession = function(sessionData, setSessionSuccess) {
    return this.setOrFetch(this.app.session, sessionData, {
      success: setSessionSuccess
    });
  };

  return SessionRouter;

})(BadassAppRouter);

});

;require.register("BadassView", function(exports, require, module) {
" BadassView add 3 basic bits of functionality to a normal Backbone.View\n1) Auto-logging of initialize, render & save\n2) Auto setting constructor args as attributes on view instances\n3) Short elm() to access an html element based on it's name attribute";
var BadassView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = BadassView = (function(_super) {
  __extends(BadassView, _super);

  BadassView.prototype.logging = false;

  BadassView.prototype.autoSetConstructorArgs = true;

  function BadassView(args) {
    var attr, value;
    if ((args != null) && (args.autoSetConstructorArgs != null)) {
      this.autoSetConstructorArgs = args.autoSetConstructorArgs;
    }
    if (this.autoSetConstructorArgs) {
      for (attr in args) {
        if (!__hasProp.call(args, attr)) continue;
        value = args[attr];
        this[attr] = value;
      }
    }
    if (this.logging) {
      this.enableLogging();
    }
    Backbone.View.prototype.constructor.apply(this, arguments);
  }

  BadassView.prototype.enableLogging = function() {
    var _this = this;
    this.viewTypeName = this.constructor.name;
    if (this.initialize != null) {
      this.initialize = _.wrap(this.initialize, function(fn, args) {
        $log("" + _this.viewTypeName + ".init", args);
        return fn.call(_this, args);
      });
    }
    if (this.render != null) {
      this.render = _.wrap(this.render, function(fn, args) {
        $log("" + _this.viewTypeName + ".render", "model", _this.model, "collection", _this.collection);
        return fn.call(_this, args);
      });
    }
    if (this.save != null) {
      return this.save = _.wrap(this.save, function(fn, args) {
        $log("" + _this.viewTypeName + ".save", args);
        return fn.call(_this, args);
      });
    }
  };

  BadassView.prototype.elm = function(attr) {
    return this.$("[name='" + attr + "']");
  };

  BadassView.prototype.mget = function(attr) {
    if (this.model != null) {
      return this.model.get(attr);
    }
  };

  return BadassView;

})(Backbone.View);

});

;require.register("EnhancedFormView", function(exports, require, module) {
var EnhancedFormView, ModelSaveView, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ModelSaveView = require('ModelSaveView');

"A view that has a bunch of tricks";

module.exports = EnhancedFormView = (function(_super) {
  __extends(EnhancedFormView, _super);

  function EnhancedFormView() {
    _ref = EnhancedFormView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  EnhancedFormView.prototype.enableCharCount = function(attr) {
    var elm,
      _this = this;
    elm = this.elm(attr);
    elm.parent().find('.charCount').html("" + (elm.val().length) + " chars");
    return elm.on('input', function() {
      return elm.parent().find('.charCount').html("" + (elm.val().length) + " chars");
    });
  };

  return EnhancedFormView;

})(ModelSaveView);

});

;require.register("HasBootstrapErrorStateView", function(exports, require, module) {
"Backbone.Validation is (should) already be available on the global scope\n\nTODO: JK(03.16.13) consider reviewing & moving backbone-validation_bootstrap\ninto this class\n";
var HasBootstrapErrorStateView, HasErrorStateView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

HasErrorStateView = require('HasErrorStateView');

module.exports = HasBootstrapErrorStateView = (function(_super) {
  __extends(HasBootstrapErrorStateView, _super);

  function HasBootstrapErrorStateView(args) {
    this.renderErrorSummary = __bind(this.renderErrorSummary, this);
    HasErrorStateView.prototype.constructor.apply(this, arguments);
  }

  HasBootstrapErrorStateView.prototype.renderErrorSummary = function(model, errors) {
    var msg;
    this.errorSummary = this.$('.alert-error');
    if (this.logging) {
      $log('renderErrorSummary', model, errors, this.errorSummary);
    }
    if (this.errorSummary.length > 0) {
      msg = errors.msg;
      if ((errors.data != null) && (errors.data.other != null)) {
        msg = "" + msg + ": " + errors.data.other;
      }
      return this.errorSummary.html(msg).fadeIn();
    }
  };

  HasBootstrapErrorStateView.prototype.renderInputInvalid = function(input, msg) {
    return Backbone.Validation.renderBootstrapInputInvalid(input, msg);
  };

  HasBootstrapErrorStateView.prototype.renderInputValid = function(input) {
    return Backbone.Validation.renderBootstrapInputValid($(input));
  };

  HasBootstrapErrorStateView.prototype.renderInputsValid = function() {
    var input, _i, _len, _ref, _results;
    _ref = this.$('input,textarea,select');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      input = _ref[_i];
      _results.push(Backbone.Validation.renderBootstrapInputValid($(input)));
    }
    return _results;
  };

  return HasBootstrapErrorStateView;

})(HasErrorStateView);

});

;require.register("HasErrorStateView", function(exports, require, module) {
var BadassView, HasErrorStateView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BadassView = require('BadassView');

" A view that is capable of rendering\n1) An error summary state\n2) Single field/input level errors\n3) Delegate to a 500 state ";

module.exports = HasErrorStateView = (function(_super) {
  __extends(HasErrorStateView, _super);

  HasErrorStateView.prototype.showSummaryOnClientError = false;

  function HasErrorStateView(args) {
    this.renderError = __bind(this.renderError, this);
    BadassView.prototype.constructor.apply(this, arguments);
  }

  /*
  expects errors from the server to look like
    {
      data: {
        fieldName: message
      }
    }
  */


  HasErrorStateView.prototype.renderError = function(model, resp, opts) {
    var attr, errors, value, _ref, _results;
    if (this.logging) {
      $log('renderError', model, resp, opts);
    }
    try {
      errors = JSON.parse(resp.responseText);
    } catch (_error) {}
    if (errors != null) {
      if (errors.code === 500) {
        return this.delegate500Error();
      }
      if (this.logging) {
        $log('errors', errors.isServer, errors);
      }
      if ((errors.isServer != null) || this.showAlertOnClientError) {
        this.renderErrorSummary(model, errors);
      }
      _ref = errors.data;
      _results = [];
      for (attr in _ref) {
        if (!__hasProp.call(_ref, attr)) continue;
        value = _ref[attr];
        if (this.logging) {
          $log('attr', attr, value);
        }
        _results.push(this.tryRenderInputInvalid(attr, value));
      }
      return _results;
    }
  };

  HasErrorStateView.prototype.delegate500Error = function() {
    return $log('HasErrorStateView.delegate500 not implemented');
  };

  HasErrorStateView.prototype.tryRenderInputInvalid = function(attr, msg) {
    var input;
    input = this.elm(attr);
    if (input.length) {
      return this.renderInputInvalid(input, msg);
    } else {
      return $log("WARN: input not found for " + attr + ". ERROR: " + (JSON.stringify(msg)));
    }
  };

  HasErrorStateView.prototype.renderInputsValid = function() {
    return $log('Subclass & renderInputsValid');
  };

  HasErrorStateView.prototype.renderErrorSummary = function() {
    return $log('Subclass & renderErrorSummary');
  };

  return HasErrorStateView;

})(BadassView);

});

;require.register("ModelSaveView", function(exports, require, module) {
var HasBootstrapErrorStateView, ModelSaveView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

HasBootstrapErrorStateView = require('./HasBootstrapErrorStateView');

"JK(03.16.13) TODO figure out how to decouple inheritance chain to use other\nErrorStateVies besides the bootstrap one";

module.exports = ModelSaveView = (function(_super) {
  __extends(ModelSaveView, _super);

  ModelSaveView.prototype.async = true;

  function ModelSaveView(args) {
    this.renderSuccess = __bind(this.renderSuccess, this);
    HasBootstrapErrorStateView.prototype.constructor.apply(this, arguments);
  }

  ModelSaveView.prototype.initialize = function() {
    throw Error('must inherit ModelSaveView & implement initialize');
  };

  ModelSaveView.prototype.save = function(e) {
    var newattrs, options;
    if (e != null) {
      e.preventDefault();
    }
    newattrs = this.getViewData();
    Backbone.Validation.unbind(this);
    Backbone.Validation.bind(this);
    if (this.logging) {
      $log('ModelSaveView.save', 'old:', this.model.toJSON(), 'new:', newattrs, 'changes:', this.model.changedAttributes(newattrs));
    }
    this.renderInputsValid();
    options = {
      success: this.renderSuccess,
      error: this.renderError,
      wait: !this.async
    };
    this.model.save(newattrs, options);
    return false;
  };

  ModelSaveView.prototype.renderSuccess = function(model, response, options) {
    if (this.logging) {
      $log('ModelSaveView.renderSuccess', this, model, response, options);
    }
    if (this.$('.alert-success').length > 0) {
      return this.$('.alert-success').fadeIn(800).fadeOut(5000);
    }
  };

  ModelSaveView.prototype.getViewData = function() {
    return this.getValsFromInputs(this.viewData);
  };

  ModelSaveView.prototype.getValsFromInputs = function(attrs) {
    var attr, obj, _i, _len;
    obj = {};
    for (_i = 0, _len = attrs.length; _i < _len; _i++) {
      attr = attrs[_i];
      obj[attr] = this.$("[name='" + attr + "']").val();
    }
    return obj;
  };

  ModelSaveView.prototype.setValsFromModel = function(attrs) {
    var attr, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = attrs.length; _i < _len; _i++) {
      attr = attrs[_i];
      _results.push(this.$("[name='" + attr + "']").val(this.model.get(attr)));
    }
    return _results;
  };

  return ModelSaveView;

})(HasBootstrapErrorStateView);

});

;
//# sourceMappingURL=backbone.badass.js.map
