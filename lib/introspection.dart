/**
* Introspection of Elements for debugging and tests.
*/
library angular.introspection;

import 'dart:async' as async;
import 'dart:html' as dom;
import 'dart:js' as js;
import 'package:di/di.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/animate/module.dart';


/**
 * A global write only variable which keeps track of objects attached to the
 * elements. This is useful for debugging AngularDart application from the
 * browser's REPL.
 */
var elementExpando = new Expando('element');


ElementProbe _findProbeWalkingUp(dom.Node node, [dom.Node ascendUntil]) {
  while (node != null && node != ascendUntil) {
    var probe = elementExpando[node];
    if (probe != null) return probe;
    node = node.parent;
  }
  return null;
}


_walkProbesInTree(dom.Node node, Function walker) {
  var probe = elementExpando[node];
  if (probe == null || walker(probe) != true) {
    for (var child in node.childNodes) {
      _walkProbesInTree(child, walker);
    }
  }
}


ElementProbe _findProbeInTree(dom.Node node, [dom.Node ascendUntil]) {
  var probe;
  _walkProbesInTree(node, (_probe) {
    probe = _probe;
    return true;
  });
  return (probe != null) ? probe : _findProbeWalkingUp(node, ascendUntil);
}


List<ElementProbe> _findAllProbesInTree(dom.Node node) {
  List<ElementProbe> probes = [];
  _walkProbesInTree(node, probes.add);
  return probes;
}


/**
 * Return the [ElementProbe] object for the closest [Element] in the hierarchy.
 *
 * The node parameter could be:
 * * a [dom.Node],
 * * a CSS selector for this node.
 *
 * **NOTE:** This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The
 * function is not intended to be called from Angular application.
 */
ElementProbe ngProbe(nodeOrSelector) {
  if (nodeOrSelector == null) throw "ngProbe called without node";
  var node = nodeOrSelector;
  if (nodeOrSelector is String) {
    var nodes = ngQuery(dom.document, nodeOrSelector);
    node = (nodes.isNotEmpty) ? nodes.first : null;
  }
  var probe = _findProbeWalkingUp(node);
  if (probe != null) {
    return probe;
  }
  var forWhat = (nodeOrSelector is String) ? "selector" : "node";
  throw "Could not find a probe for the $forWhat '$nodeOrSelector' nor its parents";
}


/**
 * Return the [Injector] associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The function
 * is not intended to be called from Angular application.
 */
Injector ngInjector(nodeOrSelector) => ngProbe(nodeOrSelector).injector;


/**
 * Return the [Scope] associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The function
 * is not intended to be called from Angular application.
 */
Scope ngScope(nodeOrSelector) => ngProbe(nodeOrSelector).scope;


List<dom.Element> ngQuery(dom.Node element, String selector,
                          [String containsText]) {
  var list = [];
  var children = [element];
  if ((element is dom.Element) && element.shadowRoot != null) {
    children.add(element.shadowRoot);
  }
  while (!children.isEmpty) {
    var child = children.removeAt(0);
    child.querySelectorAll(selector).forEach((e) {
      if (containsText == null || e.text.contains(containsText)) list.add(e);
    });
    child.querySelectorAll('*').forEach((e) {
      if (e.shadowRoot != null) children.add(e.shadowRoot);
    });
  }
  return list;
}


/**
 * Return a List of directives associated with a current [Element].
 *
 * **NOTE**: This global method is here to make it easier to debug Angular
 * application from the browser's REPL, unit or end-to-end tests. The function
 * is not intended to be called from Angular application.
 */
List<Object> ngDirectives(nodeOrSelector) => ngProbe(nodeOrSelector).directives;



js.JsObject _jsProbe(ElementProbe probe) {
  return _jsify({
      "element": probe.element,
      "injector": _jsInjector(probe.injector),
      "scope": _jsScopeFromProbe(probe),
      "directives": probe.directives.map((directive) => _jsDirective(directive)),
      "bindings": probe.bindings
  })..['_dart_'] = probe;
}


js.JsObject _jsInjector(Injector injector) =>
    _jsify({"get": injector.get})..['_dart_'] = injector;


js.JsObject _jsScopeFromProbe(ElementProbe probe) =>
    _jsScope(probe.scope, probe.injector.get(ScopeStatsConfig));



// Work around http://dartbug.com/17752
// Proxies a Dart function that accepts up to 10 parameters.
js.JsFunction _jsFunction(Function fn) {
  const Object X = __varargSentinel;
  return new js.JsFunction.withThis(
      (_, [o1=X, o2=X, o3=X, o4=X, o5=X, o6=X, o7=X, o8=X, o9=X, o10=X]) =>
          __invokeFn(fn, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10));
}


const Object __varargSentinel = const Object();


__invokeFn(fn, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10) {
  var args = [o1, o2, o3, o4, o5, o6, o7, o8, o9, o10];
  while (args.length > 0 && identical(args.last, __varargSentinel)) {
    args.removeLast();
  }
  return _jsify(Function.apply(fn, args));
}


// Helper function to JSify a Dart object.  While this is *required* to JSify
// the result of a scope.eval(), other uses are not required and are used to
// work around http://dartbug.com/17752 in a convenient way (that bug affects
// dart2js in checked mode.)
_jsify(var obj) {
  if (obj == null || obj is js.JsObject) {
    return obj;
  }
  if (obj is Function) {
    if (identical(1, 1.0)) {
      // Only do this for dart2js.  This is not simply an optimization but works
      // around a bug in Dartium when Dart code is invoking a JS function.  This
      // bug is present in dart 1.4.0 but not in dart 1.5.0-dev.2.0.
      // Specifically, if you call .apply([args]) or .callMethod(name, [args])
      // on a JsFunction, in 1.4.0, the first param ends up as thisArg (even if
      // you specify a thisArg to the apply call.)
      return _jsFunction(obj);
    }
  }
  if ((obj is Map) || (obj is Iterable)) {
    var mappedObj = (obj is Map) ? 
        new Map.fromIterables(obj.keys, obj.values.map(_jsify)) : obj.map(_jsify);
    if (obj is List) {
      mappedObj = new js.JsArray.from(mappedObj);
    }
    return new js.JsObject.jsify(mappedObj)..['_dart_'] = obj;
  }
  return obj;
}


js.JsObject _jsScope(Scope scope, ScopeStatsConfig config) {
  return _jsify({
      "apply": scope.apply,
      "broadcast": scope.broadcast,
      "context": scope.context,
      "destroy": scope.destroy,
      "digest": scope.rootScope.digest,
      "emit": scope.emit,
      "flush": scope.rootScope.flush,
      "get": (name) => scope.context[name],
      "isAttached": scope.isAttached,
      "isDestroyed": scope.isDestroyed,
      "set": (name, value) => scope.context[name] = value,
      "scopeStatsEnable": () => config.emit = true,
      "scopeStatsDisable": () => config.emit = false,
      r"$eval": (expr) => _jsify(scope.eval(expr)),
  })..['_dart_'] = scope;
}


_jsDirective(directive) => directive;


abstract class _JsObjectProxyable {
  js.JsObject _toJsObject();
}


/**
 * Returns the "$testability service" object for JS / Protractor use.
 *
 * JS code expects to get a hold of this object in the following way:
 *
 *   // Prereq: There is an "angular" object on window accessible via JS.
 *   var testability = angular.element(document).injector().get('$testability');
 */
class _Testability implements _JsObjectProxyable {
  dom.Node node;
  Injector injector;

  _Testability(this.node, this.injector);

  notifyWhenNoOutstandingRequests(callback) {
    injector.get(VmTurnZone).run(
        () => new async.Timer(Duration.ZERO, callback));
  }

  _findByModel(model) {
    // DELETED:  Is it worth doing something like _findBindings here?  I had the
    // code (find NgModel in the probe.directives in the tree.  In order to
    // compare the model expression, I either looked it up on the node, or
    // made _expression public in NgModel.  The former then reduces more or less
    // to what protractor used to do - but now we're doing more work.  The
    // latter opens up private parts.
    throw "Should not reach here - the protractor JS version should have been called.";
  }

  /**
   * Returns a list of all nodes in the selected tree that have `ng-bind` or
   * mustache bindings specified by the [bindingString].  If the optional
   * [exactMatch] parameter is provided and true, it restricts the searches to
   * bindings that are exact matches for [bindingString].
   */
  List<dom.Node> findBindings(String bindingString, [bool exactMatch]) {
    List<ElementProbe> probes = _findAllProbesInTree(node);
    if (probes.length == 0) {
      probes.add(_findProbeWalkingUp(node));
    }
    List<dom.Node> results = [];
    for (ElementProbe probe in probes) {
      for (String binding in probe.bindings) {
        int index = binding.indexOf(bindingString);
        if (index >= 0 && (index == 0 || exactMatch != true)) {
          results.add(probe.element);
        }
      }
    }
    return results;
  }

  js.JsObject _toJsObject() {
    return _jsify({
       'findBindings': (bindingString, [exactMatch]) =>
           findBindings(bindingString, exactMatch),
       'notifyWhenNoOutstandingRequests': (callback) =>
         notifyWhenNoOutstandingRequests(() => callback.apply([])),
    })..['_dart_'] = this;
  }
}


class _TestabilityInjector implements _JsObjectProxyable {
  Injector injector;
  _Testability testability;
  dom.Node node;

  _TestabilityInjector(dom.Node this.node, Injector this.injector) {
    testability=new _Testability(node, injector);
  }

  get(String what) {
    if (what == r'$testability') {
      return testability;
    }
    return null;
  }

  js.JsObject _toJsObject() {
    return _jsify({
      'get': (what) => get(what)._toJsObject(),
    })..['_dart_'] = this;
  }
}


_allowAnimations(bool enabled, [dom.Node node]) {
  Injector injector;
  if (node == null) {
    injector = _findProbeInTree(dom.document).injector;
  } else {
    injector = ngInjector(node);
  }
  AnimationOptimizer optimizer = injector.get(AnimationOptimizer);
  if (optimizer != null) {
    optimizer.animationsAllowed = (enabled == true);
  }
}


class _TestabilityElement implements _JsObjectProxyable {
  dom.Node node;
  _TestabilityInjector testabilityInjector;
  ElementProbe probe;

  _TestabilityElement(this.node) {
    probe = _findProbeInTree(node);
    testabilityInjector = new _TestabilityInjector(node, probe.injector);
  }

  injector() => testabilityInjector;
  scope() => probe.scope;

  js.JsObject _toJsObject() {
    return _jsify({
      'injector': () => injector()._toJsObject(),
      'probe': () => _jsProbe(probe),
      'scope': () => _jsScopeFromProbe(probe),
      'allowAnimations': (bool allowed) => _allowAnimations(allowed, node),
    })..['_dart_'] = this;
  }
}


void publishToJavaScript() {
  var D = {};
  D['ngProbe'] = (nodeOrSelector) => _jsProbe(ngProbe(nodeOrSelector));
  D['ngInjector'] = (nodeOrSelector) => _jsInjector(ngInjector(nodeOrSelector));
  D['ngScope'] = (nodeOrSelector) => _jsScopeFromProbe(ngProbe(nodeOrSelector));
  D['ngQuery'] = (dom.Node node, String selector, [String containsText]) =>
      ngQuery(node, selector, containsText);
  D['angular'] = {
        'resumeBootstrap': ([arg]) {},
        'allowAnimations': _allowAnimations,
        'element': (node) => new _TestabilityElement(node)._toJsObject(),
  };
  js.JsObject J = _jsify(D);
  for (String key in D.keys) {
    js.context[key] = J[key];
  }
}
