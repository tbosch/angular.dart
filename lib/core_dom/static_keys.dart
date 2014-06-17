library angular.core_dom.static_keys;

import 'dart:html' as dom;
import 'package:di/di.dart';
import 'package:angular/core/static_keys.dart';
import 'package:angular/core_dom/module_internal.dart';

export 'package:angular/directive/static_keys.dart' show NG_BASE_CSS_KEY;
export 'package:angular/core/static_keys.dart';

// Keys used to call Injector.getByKey and Module.bindByKey

final Key ANIMATE_KEY = new Key(Animate);
final Key BOUND_VIEW_FACTORY_KEY = new Key(BoundViewFactory);
final Key COMPILER_KEY = new Key(Compiler);
final Key COMPONENT_CSS_REWRITER_KEY = new Key(ComponentCssRewriter);
final Key DIRECTIVE_MAP_KEY = new Key(DirectiveMap);
final Key ELEMENT_KEY = new Key(dom.Element);
final Key ELEMENT_PROBE_KEY = new Key(ElementProbe);
final Key EVENT_HANDLER_KEY = new Key(EventHandler);
final Key EXPANDO_KEY = new Key(Expando);
final Key HTTP_KEY = new Key(Http);
final Key NG_ELEMENT_KEY = new Key(NgElement);
final Key NODE_ATTRS_KEY = new Key(NodeAttrs);
final Key NODE_KEY = new Key(dom.Node);
final Key NODE_TREE_SANITIZER_KEY = new Key(dom.NodeTreeSanitizer);
final Key SHADOW_ROOT_KEY = new Key(dom.ShadowRoot);
final Key TEMPLATE_CACHE_KEY = new Key(TemplateCache);
final Key TEMPLATE_LOADER_KEY = new Key(TemplateLoader);
final Key TEXT_MUSTACHE_KEY = new Key(TextMustache);
final Key VIEW_CACHE_KEY = new Key(ViewCache);
final Key VIEW_FACTORY_KEY = new Key(ViewFactory);
final Key VIEW_KEY = new Key(View);
final Key VIEW_PORT_KEY = new Key(ViewPort);
final Key WEB_PLATFORM_KEY = new Key(WebPlatform);
final Key WINDOW_KEY = new Key(dom.Window);
