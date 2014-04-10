part of angular.directive;

@Decorator(
    selector: '[ng-base-css]',
    visibility: Directive.CHILDREN_VISIBILITY
)
class NgBaseCss implements AttachAware {

  List<String> _urls = const [];

  var _completer = new async.Completer();

  @NgAttr('ng-base-css')
  set urls(v) {
    return _urls = v is List ? v : [v];
  }

  async.Future<List<String>> get urls {
    return _completer.future;
  }

  attach() {
    _completer.complete(_urls);
  }
}

class RootNgBaseCss implements NgBaseCss {
  set urls(_) { }

  get urls => new async.Future.value([]);

  attach() { }

  // Make the analyzer happy
  var _urls = null;
  var _completer = null;
}
