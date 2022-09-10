import 'statement/statement.dart';

class Migration {
  /// The version to migrate from. `0.0.0` for the initial migration.
  final String from;

  /// The version to migrate to:
  /// - bump major version for breaking schema changes
  /// - bump minor version for non-breaking schema changes
  /// - bump patch version for changes within the same migration context
  final String to;

  /// The description of the migration.
  final String description;

  /// Statements to run for the migration forward.
  final List<Statement> forward;

  /// Statements to run for the migration backward.
  final List<Statement> backward;

  /// Conditions to check before going forward or after going backward.
  final List<ExpectedQueryResult>? before;

  /// Conditions to check before going backward or after going forward.
  final List<ExpectedQueryResult>? after;

  Migration({
    required this.from,
    required this.to,
    required this.description,
    required this.forward,
    required this.backward,
    this.before,
    this.after,
  });
}

class ExpectedQueryResult {
  final ResultStatement query;
  final List<List<ValueExpectation>> expectations;

  ExpectedQueryResult(this.query, List<List<dynamic>> expectations)
      : expectations = expectations
            .map((row) => row.map((cell) {
                  if (cell is ValueExpectation) {
                    return cell;
                  }
                  if (cell == null ||
                      cell is num ||
                      cell is bool ||
                      cell is String) {
                    return ValueExpectation(cell);
                  }
                  throw ArgumentError(
                      'Unknown expecation: ${cell.runtimeType}: $cell');
                }).toList())
            .toList();
}

class ValueExpectation {
  final String op;
  final dynamic value;

  ValueExpectation(this.value) : op = '=';

  bool matchesExpectation(dynamic actual) {
    switch (op) {
      case '=':
        return actual == value;
    }
    throw UnimplementedError('"$op" is not implemented');
  }
}
