import '../dialect.dart';
import '../expr/expr.dart';

part '_definition.dart';
part '_manipulation.dart';
part '_result.dart';
part '_shared.dart';

abstract class Statement extends SqlPart {}

abstract class DefinitionStatement extends Statement {}

abstract class ManipulationStatement extends Statement {}

abstract class ResultStatement<R> extends Statement {}

abstract class Relation {}
