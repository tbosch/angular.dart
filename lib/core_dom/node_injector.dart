library angular.node_injector;

import 'dart:collection';
import 'dart:html' show Node, Element, ShadowRoot;
import 'dart:profiler';

import 'package:di/di.dart';
import 'package:di/src/base_injector.dart';
import 'package:angular/core/static_keys.dart';
import 'package:angular/core_dom/static_keys.dart';
import 'package:angular/mock/module.dart';

import 'package:angular/core/module.dart' show Scope;
import 'package:angular/core/annotation.dart' show Visibility;
import 'package:angular/core_dom/module_internal.dart'
  show View, ViewFactory, BoundViewFactory, ViewPort, NodeAttrs, ElementProbe,
      NgElement, ContentPort, TemplateLoader, ShadowRootEventHandler, EventHandler;

var tag_get = new UserTag('NodeInjector.get()');
var tag_instantiate = new UserTag('NodeInjector.instantiate()');

final CONTENT_PORT_KEY = new Key(ContentPort);
final TEMPLATE_LOADER_KEY = new Key(TemplateLoader);
final SHADOW_ROOT_KEY = new Key(ShadowRoot);

const int INJECTOR_KEY_ID           = 0;
const int NODE_KEY_ID               = 1;
const int ELEMENT_KEY_ID            = 2;
const int NODE_ATTRS_KEY_ID         = 3;
const int SCOPE_KEY_ID              = 4;
const int VIEW_KEY_ID               = 5;
const int VIEW_PORT_KEY_ID          = 6;
const int VIEW_FACTORY_KEY_ID       = 7;
const int NG_ELEMENT_KEY_ID         = 8;
const int BOUND_VIEW_FACTORY_KEY_ID = 9;
const int ELEMENT_PROBE_KEY_ID      = 10;
const int TEMPLATE_LOADER_KEY_ID    = 11;
const int SHADOW_ROOT_KEY_ID        = 12;
const int CONTENT_PORT_KEY_ID       = 13;
const int EVENT_HANDLER_KEY_ID      = 14;

class NodeInjector implements Injector {
  static bool _isInit = false;
  static initUID() {
    if (_isInit) return;
    _isInit = true;
    INJECTOR_KEY.uid           = INJECTOR_KEY_ID;
    NODE_KEY.uid               = NODE_KEY_ID;
    ELEMENT_KEY.uid            = ELEMENT_KEY_ID;
    NODE_ATTRS_KEY.uid         = NODE_ATTRS_KEY_ID;
    SCOPE_KEY.uid              = SCOPE_KEY_ID;
    VIEW_KEY.uid               = VIEW_KEY_ID;
    VIEW_PORT_KEY.uid          = VIEW_PORT_KEY_ID;
    VIEW_FACTORY_KEY.uid       = VIEW_FACTORY_KEY_ID;
    NG_ELEMENT_KEY.uid         = NG_ELEMENT_KEY_ID;
    BOUND_VIEW_FACTORY_KEY.uid = BOUND_VIEW_FACTORY_KEY_ID;
    ELEMENT_PROBE_KEY.uid      = ELEMENT_PROBE_KEY_ID;
    TEMPLATE_LOADER_KEY.uid    = TEMPLATE_LOADER_KEY_ID;
    SHADOW_ROOT_KEY.uid        = SHADOW_ROOT_KEY_ID;
    CONTENT_PORT_KEY.uid       = CONTENT_PORT_KEY_ID;
    EVENT_HANDLER_KEY.uid      = EVENT_HANDLER_KEY_ID;
  }
  
  final Injector parent;
  final Node _node;
  final NodeAttrs _nodeAttrs;
  final View _view;
  final ViewPort _viewPort;
  final ViewFactory _viewFactory;
  Scope scope;

  BoundViewFactory _boundViewFactory;
  NgElement _ngElement;
  ElementProbe _elementProbe;

  Key _key_0 = null;
  dynamic _instance_0;
  List<Key> _paramKeyIds_0;
  Factory _constructor_0;

  Key _key_1 = null;
  dynamic _instance_1;
  List<Key> _paramKeyIds_1;
  Factory _constructor_1;

  Key _key_2 = null;
  dynamic _instance_2;
  List<Key> _paramKeyIds_2;
  Factory _constructor_2;

  NodeInjector(this.parent, this._node, this._nodeAttrs,
               this._view, this._viewPort, this._viewFactory,
               this.scope);

  // TODO(misko): this constructor is suspicious
  NodeInjector.scopeOnly(this.parent, this.scope)
    : _node = null, _nodeAttrs = null, _view = null, _viewPort = null, _viewFactory = null;

  addDirective(Key key, Factory factory, List<Key> parameterKeys, Visibility visibility) {
    // TODO(misko): implement visibility.
    if (_key_0 == null) {
      _key_0 = key;
      _paramKeyIds_0 = parameterKeys;
      _constructor_0 = factory;
    } else if (_key_1 == null) {
      _key_1 = key;
      _paramKeyIds_1 = parameterKeys;
      _constructor_1 = factory;
    } else if (_key_2 == null) {
      _key_2 = key;
      _paramKeyIds_2 = parameterKeys;
      _constructor_2 = factory;
    } else {
      throw 'No Space!!!';
    }
  }

  Object get(Type type) => getByKey(new Key(type));

  Object getByKey(Key key) {
    var oldTag = tag_get.makeCurrent();
    var keyId = key.uid;
    var obj;
    if (identical(keyId, INJECTOR_KEY_ID)) {
      obj = this;
    } else if (identical(keyId, NODE_KEY_ID) || identical(keyId, ELEMENT_KEY_ID)) {
      obj = _node;
    } else if (identical(keyId, NODE_ATTRS_KEY_ID)) {
      obj = _nodeAttrs;
    } else if (identical(keyId, SCOPE_KEY_ID)) {
      obj = scope;
    } else if (identical(keyId, VIEW_KEY_ID)) {
      obj = _view;
    } else if (identical(keyId, VIEW_PORT_KEY_ID)) {
      obj = _viewPort;
    } else if (identical(keyId, VIEW_FACTORY_KEY_ID)) {
      obj = _viewFactory;
    } else if (identical(keyId, NG_ELEMENT_KEY_ID)) {
      obj = _ngElement == null ? _ngElement = new NgElement(_node, scope, parent.getByKey(ANIMATE_KEY)) : _ngElement;
    } else if (identical(keyId, BOUND_VIEW_FACTORY_KEY_ID)) {
      obj = _boundViewFactory == null ? _boundViewFactory = _viewFactory.bind(this) : _boundViewFactory;
    } else if (identical(keyId, ELEMENT_PROBE_KEY_ID)) {
      obj = elementProbe;
    } else if (identical(key, _key_0)) {
      if (identical(null, _instance_0)) _instance_0 = _newInstance(_paramKeyIds_0, _constructor_0);
      obj = _instance_0;
    } else if (identical(key, _key_1)) {
      if (identical(null, _instance_1)) _instance_1 = _newInstance(_paramKeyIds_1, _constructor_1);
      obj = _instance_1;
    } else if (identical(key, _key_2)) {
      if (identical(null, _instance_2)) _instance_2 = _newInstance(_paramKeyIds_2, _constructor_2);
      obj = _instance_2;
    } else {
      obj = parent.getByKey(key);
    }
    oldTag.makeCurrent();
    return obj;
  }

  dynamic _newInstance(List<Key> paramKeys, Function constructor) {
    var params = new List(paramKeys.length);
    for(var i = 0; i < paramKeys.length; i++) {
      params[i] = getByKey(paramKeys[i]);
    }
    var oldTag = tag_instantiate.makeCurrent();
    var obj = constructor(params);
    oldTag.makeCurrent();
    return obj;
  }


  get elementProbe {
    if (_elementProbe == null) {
      ElementProbe parentProbe = parent is NodeInjector ? parent.elementProbe : null;
      _elementProbe = new ElementProbe(parentProbe, _node, this, scope);
    }
    return _elementProbe;
  }
}

abstract class ComponentNodeInjector extends NodeInjector {

  final TemplateLoader _templateLoader;
  final ShadowRoot _shadowRoot;

  ComponentNodeInjector(NodeInjector parent, Node node, Scope scope,
                        this._templateLoader, this._shadowRoot)
      : super(parent, node, null, parent._view, parent._viewPort,
              parent._viewFactory, scope);

  getByKey(Key key) {
    int keyId = key.uid;
    var obj;
    if (identical(keyId, TEMPLATE_LOADER_KEY_ID)) {
      obj = _templateLoader;
    } else if (identical(keyId, SHADOW_ROOT_KEY_ID)) {
      obj = _shadowRoot;
    } else {
      obj = super.getByKey(key);
    }
    return obj;
  }
}

class ShadowlessComponentNodeInjector extends ComponentNodeInjector {
  final ContentPort _contentPort;

  ShadowlessComponentNodeInjector(NodeInjector parent, Scope scope,
                                 templateLoader, shadowRoot, this._contentPort)
  : super(parent, parent._node, scope, templateLoader, shadowRoot);

  getByKey(Key key) {
    int keyId = key.uid;
    var obj;
    if (identical(keyId, CONTENT_PORT_KEY_ID)) {
      obj = _contentPort; 
    } else {
      obj = super.getByKey(key);
    }
    return obj;
  }
}
class ShadowDomComponentNodeInjector extends ComponentNodeInjector {
  ShadowRootEventHandler _eventHandler;

  ShadowDomComponentNodeInjector(NodeInjector parent, Scope scope,
                              templateLoader, shadowRoot)
    : super(parent, parent._node, scope, templateLoader, shadowRoot);

  getByKey(Key key) {
    int keyId = key.uid;
    var obj;
    if (identical(keyId, EVENT_HANDLER_KEY_ID)) {
      obj = eventHandler;
    } else {
      obj = super.getByKey(key);
    }
    return obj;
  }

  ShadowRootEventHandler get eventHandler {
    if (_eventHandler == null) {
      var expando = getByKey(EXPANDO_KEY);
      var exceptionHandler = getByKey(EXCEPTION_HANDLER_KEY);
      _eventHandler = new ShadowRootEventHandler(_shadowRoot, expando, exceptionHandler);
    }
    return _eventHandler;
  }
}
