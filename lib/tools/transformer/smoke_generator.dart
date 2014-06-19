library angular.tools.transformer.smoke_generator;

import 'dart:async';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:smoke/codegen/generator.dart';
import 'package:smoke/codegen/recorder.dart';
import 'package:path/path.dart' as path;

/**
 * Extract code metadata needed by the [Observable] implementation in the dccd.
 *
 * During development, those metadata are retrieved thanks to mirrors but those are not available
 * in production to minimize the generated code size.
 *
 * The `SmokeGenerator` transformer generates a dart file to initialize the `smoke` package.
 */
class SmokeGenerator extends Transformer with ResolverTransformer {
  final generator = new SmokeCodeGenerator();

  SmokeGenerator(Resolvers resolvers) {
    this.resolvers = resolvers;
  }

  /// Transform dart files only
  @override
  String get allowedExtensions => '.dart';

  @override
  applyResolver(Transform transform, Resolver resolver) {
    var asset = transform.primaryInput;
    var id = asset.id;

    var outputFilename = '${path.url.basenameWithoutExtension(id.path)}_static_smoke.dart';
    var outputPath = path.url.join(path.url.dirname(id.path), outputFilename);
    var outputId = new AssetId(id.package, outputPath);
    var outputBuffer = new StringBuffer();

    var reflectableElement = resolver.getType('observe.src.metadata.Reflectable');

    if (reflectableElement == null) {
      transform.logger.warning('Unable to resolve "observe.src.metadata.Reflectable"');
    }

    var recorder = new Recorder(
      generator, (lib) => resolver.getImportUri(lib, from: outputId).toString());

    void _extract(ClassElement cls) {
      // todo(vicb) smoke does not handle generic type well, skip <T> value - dartbug.com/ 18491
      if (cls.library.name == 'observe.src.observable_box') return;
      recorder.runQuery(cls, new QueryOptions(
          includeFields: true,
          includeProperties: true,
          includeInherited: false,
          includeUpTo: null,
          excludeFinal: true,
          includeMethods: false,
          withAnnotations: [reflectableElement],
          matches: null
      ));
    }

    resolver.libraries
        .where((lib) => !lib.isInSdk)
        .expand((lib) => lib.units)
        .expand((unit) => unit.types)
        .forEach((cls) => _extract(cls));

    var libPath = path.withoutExtension(id.path).replaceAll('/', '.').replaceAll('-', '_');

    outputBuffer.writeln('library ${id.package}.$libPath.smoke_static;');
    generator..writeTopLevelDeclarations(outputBuffer)
             ..writeImports(outputBuffer);
    outputBuffer.writeln('void init() {');
    generator..writeInitCall(outputBuffer);
    outputBuffer.writeln('}');

    transform..addOutput(new Asset.fromString(outputId, outputBuffer.toString()))
             ..addOutput(asset);
  }
}